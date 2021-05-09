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

  /**
   * Update the specified resource in storage.
   *
   * @param \Illuminate\Http\Request $request
   * @param string $username
   * @return \Illuminate\Http\JsonResponse
   */
  public function update(Request $request, $username)
  {
    $validated = $request->validate([
      'email' => 'unique:account|email'
    ]);
    $client = Client::find($username);
    $this->authorize('update', $client);

    $client->account()->email = empty($validated->input('email')) ? $client->account()->email : $validated->input('email');
    $client->account()->password = empty($validated->input('password')) ? $client->account()->password : $validated->input('password');
    $client->fullname = empty($validated->input('fullname')) ? $client->fullname : $validated->input('fullname');
    $client->company = empty($validated->input('company')) ? $client->company : $validated->input('company');
    $client->avatar = empty($validated->input('avatar')) ? $client->avatar : $validated->input('avatar');
    $client->gender = empty($validated->input('gender')) ? $client->gender : $validated->input('gender');
    $client->country = empty($validated->input('country')) ? $client->country : $validated->input('country');
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
