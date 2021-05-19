<?php

namespace App\Http\Controllers;

use App\Models\Account;
use App\Models\Client;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ClientController extends Controller
{
  public function __construct()
  {
    $this->middleware('auth');
  }

  /**
   * Display the specified resource.
   *
   * @param string $username
   * @param \Illuminate\Http\Request $request
   * @return \Illuminate\Contracts\Foundation\Application|\Illuminate\Contracts\View\Factory|\Illuminate\Contracts\View\View|\Illuminate\Http\JsonResponse
   */
  public function show(Request $request, $username)
  {
    $account = Account::where('username', '=', $username)->first();
    if ($account == null) return view('errors.404');
    $client = Client::find($account->id);
    return view('pages.profile', ['client' => $client, 'user' => Client::find(Auth::user()->id)]);
  }

  public function list(Request $request)
  {
    $searchQuery = $request->input('query');
    $project = $request->input('project');

    $clients = Client::when(!empty($searchQuery), function ($query) use ($searchQuery) {
        return $query->whereRaw('search @@ plainto_tsquery(\'english\', ?)', [$searchQuery])
          ->orderByRaw('ts_rank(search, plainto_tsquery(\'english\', ?)) DESC', [$searchQuery]);
      })->when(!empty($project), function ($query) use ($project) {
      return $query->whereDoesntHave('projects', function ($q) use ($project) {
        $q->where('project_id','=', $project);
      })->whereDoesntHave('invites', function ($q) use ($project) {
        $q->where('project_id', '=', $project);
      });
    })->paginate(5);


    $view = view('partials.createProjectMembers', ['clients' => $clients, 'pagination' => true])->render();

    return response()->json($view);
  }

  /**
   * Update the specified resource in storage.
   *
   * @param \Illuminate\Http\Request $request
   * @param string $username
   * @return \Illuminate\Http\JsonResponse
   */
  public function update(Request $request, $username)
  {
    $request->validate([
      'email' => 'nullable|unique:account|email'
    ]);
    $account = Account::where('username', '=', $username)->first();
    $client = Client::find($account->id);
    $this->authorize('update', $client);

    $account->email = empty($request->input('email')) ? $account->email : $request->input('email');
    $account->password = empty($request->input('password')) ? $account->password : $request->input('password');
    $client->fullname = empty($request->input('fullname')) ? $client->fullname : $request->input('fullname');
    $client->company = empty($request->input('company')) ? $client->company : $request->input('company');
    $client->avatar = empty($request->input('avatar')) ? $client->avatar : $request->input('avatar');
    $client->client_gender = empty($request->input('client_gender')) ? $client->client_gender : $request->input('client_gender');
    $client->country = empty($request->input('country')) ? $client->country : $request->input('country');
    $client->save();

    return response()->json($client);
  }

  /**
   * Remove the specified resource from storage.
   *
   * @param \Illuminate\Http\Request $request
   * @param string $username
   * @return
   */
  public function delete(Request $request, $username)
  {
    $account = Account::where('username', '=', $username)->first();
    $client = Client::find($account->id);
    $this->authorize('delete', [$client, Auth::user()->is_admin]);
    $client->delete();

    if (Auth::user()->is_admin)
      return response()->json($client);

    return redirect(route('/'));
  }

  /**
   * Remove the specified resource from storage.
   *
   * @param \Illuminate\Http\Request $request
   * @return
   */
  public function showSettings(Request $request)
  {
    $client = Client::find(Auth::user()->id);
    $this->authorize('showSettings', $client);
    return view('pages.settings', ['user' => $client]);
  }

  /**
   * Remove the specified resource from storage.
   *
   * @param \Illuminate\Http\Request $request
   * @return \Illuminate\Http\JsonResponse
   */
  public function updateSettings(Request $request)
  {
    $request->validate([
      'allow_noti' => 'boolean',
      'invite_noti' => 'boolean',
      'member_noti' => 'boolean',
      'assign_noti' => 'boolean',
      'waiting_noti' => 'boolean',
      'comment_noti' => 'boolean',
      'report_noti' => 'boolean',
      'hide_completed' => 'boolean',
      'simplified_tasks' => 'boolean',
      'color' => 'string',
    ]);

    $client = Client::find(Auth::id());
    $this->authorize('updateSettings', $client);

    if ($request->input('allow_noti') != null)
      $client->allow_noti = filter_var($request->input('allow_noti'), FILTER_VALIDATE_BOOLEAN);
    if ($request->input('invite_noti') != null)
      $client->invite_noti = filter_var($request->input('invite_noti'), FILTER_VALIDATE_BOOLEAN);
    if ($request->input('member_noti') != null)
      $client->memberNoti = filter_var($request->input('member_noti'), FILTER_VALIDATE_BOOLEAN);
    if ($request->input('assign_noti') != null)
      $client->assign_noti = filter_var($request->input('assign_noti'), FILTER_VALIDATE_BOOLEAN);
    if ($request->input('waiting_noti') != null)
      $client->waiting_noti = filter_var($request->input('waiting_noti'), FILTER_VALIDATE_BOOLEAN);
    if ($request->input('comment_noti') != null)
      $client->comment_noti = filter_var($request->input('comment_noti'), FILTER_VALIDATE_BOOLEAN);
    if ($request->input('report_noti') != null)
      $client->report_noti = filter_var($request->input('report_noti'), FILTER_VALIDATE_BOOLEAN);
    if ($request->input('hide_completed') != null)
      $client->hide_completed = filter_var($request->input('hide_completed'), FILTER_VALIDATE_BOOLEAN);
    if ($request->input('simplified_tasks') != null)
      $client->simplified_tasks = filter_var($request->input('simplified_tasks'), FILTER_VALIDATE_BOOLEAN);
    if ($request->input('color') != null)
      $client->color = $request->input('color');

    $client->save();

    return response()->json($client);
  }
}
