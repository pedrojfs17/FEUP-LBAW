<?php

namespace App\Http\Controllers;

use App\Models\Account;
use App\Models\Client;
use App\Models\SocialMediaAccount;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Laravel\Socialite\Facades\Socialite;

class SocialMediaAccountController extends Controller
{
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

  public function google() {
    return Socialite::driver('google')->redirect();
  }

  public function googleRedirect() {
    $user = Socialite::driver('google')->user();

    $user = Account::firstOrCreate([
      'email' => $user->email
    ],[
      'username' => explode("@", $user->email)[0],
      'password' => Hash::make(Str::random(24))
    ]);

    if (Client::find($user->id) == null) {
      Client::create([
        'id' => $user->id,
        'color' => '#' . str_pad(dechex(rand(0x000000, 0xFFFFFF)), 6, 0, STR_PAD_LEFT),
      ]);
    }

    Auth::login($user);

    return redirect('/dashboard');
  }
}
