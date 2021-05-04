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
    $client = Client::find($username);
    return response()->json($client);
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
   * @return \Illuminate\Http\JsonResponse
   */
  public function delete(Request $request, $username)
  {
    $client = Client::find($username);
    $this->authorize('delete', $client);
    $client->delete();
    return response()->json($client);
  }

  /**
   * Remove the specified resource from storage.
   *
   * @param \Illuminate\Http\Request $request
   * @return \Illuminate\Http\Response
   */
  public function showSettings(Request $request)
  {
    $client = Client::find(Auth::user()->id);
    $this->authorize('showSettings', $client);
    return view('pages.settings', ['client' => $client]);
  }

  /**
   * Remove the specified resource from storage.
   *
   * @param \Illuminate\Http\Request $request
   * @return \Illuminate\Http\JsonResponse
   */
  public function updateSettings(Request $request)
  {
    $validated = $request->validate([
      'allowNoti' => 'boolean',
      'inviteNoti' => 'boolean',
      'memberNoti' => 'boolean',
      'assignNoti' => 'boolean',
      'waitingNoti' => 'boolean',
      'commentNoti' => 'boolean',
      'reportNoti' => 'boolean',
      'hideCompleted' => 'boolean',
      'simplifiedTasks' => 'boolean',
      'color' => 'string',
    ]);
    $client = Client::find(Auth::id());
    $this->authorize('updateSettings', $client);
    $client->allowNoti = empty($validated->input('allowNoti')) ? $client->allowNoti : $validated->input('allowNoti');
    $client->inviteNoti = empty($validated->input('inviteNoti')) ? $client->inviteNoti : $validated->input('inviteNoti');
    $client->memberNoti = empty($validated->input('memberNoti')) ? $client->memberNoti : $validated->input('memberNoti');
    $client->assignNoti = empty($validated->input('assignNoti')) ? $client->assignNoti : $validated->input('assignNoti');
    $client->waitingNoti = empty($validated->input('waitingNoti')) ? $client->waitingNoti : $validated->input('waitingNoti');
    $client->commentNoti = empty($validated->input('commentNoti')) ? $client->commentNoti : $validated->input('commentNoti');
    $client->reportNoti = empty($validated->input('reportNoti')) ? $client->reportNoti : $validated->input('reportNoti');
    $client->hideCompleted = empty($validated->input('hideCompleted')) ? $client->hideCompleted : $validated->input('hideCompleted');
    $client->simplifiedTasks = empty($validated->input('simplifiedTasks')) ? $client->simplifiedTasks : $validated->input('simplifiedTasks');
    $client->color = empty($validated->input('color')) ? $client->color : $validated->input('color');
    $client->save();
    return response()->json($client);
  }
}
