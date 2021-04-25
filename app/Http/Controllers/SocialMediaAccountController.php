<?php

namespace App\Http\Controllers;

use App\Models\SocialMediaAccount;
use Illuminate\Http\Request;

class SocialMediaAccountController extends Controller
{
  /**
   * Display the specified resource.
   *
   * @return \Illuminate\Http\Response
   */
  public function list()
  {
    if (!Auth::check()) return redirect('login');
    $this->authorize('list', SocialMediaAccount::class);
    return Response::json(Auth::user()->socialMediaAccounts()->orderBy('id')->get());
  }

  /**
   * Show the form for creating a new resource.
   *
   * @return \Illuminate\Http\Response
   */
  public function create(Request $request)
  {
    if (!Auth::check()) return redirect('login');

    $validated = $request->validate([
      'website' => 'required|url|string',
      'username' => 'required|string',
      'access_token' => 'required|string'
    ]);

    $social_media_account = new SocialMediaAccount();
    $this->authorize('create', $social_media_account);
    $social_media_account->website = $validated->input('website');
    $social_media_account->username = $validated->input('username');
    $social_media_account->access_token = $validated->input('access_token');
    $social_media_account->save();
    return $social_media_account;

  }

  /**
   * Display the specified resource.
   *
   * @param int $id
   * @param \Illuminate\Http\Request $request
   * @return \Illuminate\Http\Response
   */
  public function show(Request $request, $id)
  {
    if (!Auth::check()) return redirect('login');
    $social_media_account = SocialMediaAccount::find($id);
    $this->authorize('show', $social_media_account);
    return Response::json($social_media_account);
  }

  /**
   * Remove the specified resource from storage.
   *
   * @param \App\Models\Project $project
   * @return \Illuminate\Http\Response
   */
  public function delete(Request $request, $id)
  {
    if (!Auth::check()) return redirect('login');
    $social_media_account = SocialMediaAccount::find($id);
    $this->authorize('delete', $social_media_account);
    $social_media_account->delete();
    return $social_media_account;
  }
}
