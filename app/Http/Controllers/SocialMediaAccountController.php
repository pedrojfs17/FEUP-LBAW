<?php

namespace App\Http\Controllers;

use App\Models\SocialMediaAccount;
use Illuminate\Http\Request;

class SocialMediaAccountController extends Controller
{
  public function __construct()
  {
    $this->middleware('auth');
  }

  /**
   * Display the specified resource.
   *
   * @return \Illuminate\Http\JsonResponse
   */
  public function list()
  {
    $accounts = Client::find(Auth::user()->id)->socialMediaAccounts()->orderBy('id')->get();
    return response()->json($accounts);
  }

  /**
   * Show the form for creating a new resource.
   *
   * @return \Illuminate\Http\JsonResponse
   */
  public function create(Request $request)
  {
    $validated = $request->validate([
      'website' => 'required|url|string',
      'username' => 'required|string',
      'access_token' => 'required|string'
    ]);

    $social_media_account = new SocialMediaAccount();
    $social_media_account->website = $validated->input('website');
    $social_media_account->username = $validated->input('username');
    $social_media_account->access_token = $validated->input('access_token');
    $social_media_account->save();

    return response()->json($social_media_account);
  }

  /**
   * Display the specified resource.
   *
   * @param int $id
   * @param \Illuminate\Http\Request $request
   * @return \Illuminate\Http\JsonResponse
   */
  public function show(Request $request, $id)
  {
    $social_media_account = SocialMediaAccount::find($id);
    $this->authorize('show', $social_media_account);
    return response()->json($social_media_account);
  }

  /**
   * Remove the specified resource from storage.
   *
   * @param \App\Models\Project $project
   * @return \Illuminate\Http\JsonResponse
   */
  public function delete(Request $request, $id)
  {
    $social_media_account = SocialMediaAccount::find($id);
    $this->authorize('delete', $social_media_account);
    $social_media_account->delete();
    return response()->json($social_media_account);
  }
}
