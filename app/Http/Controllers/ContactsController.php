<?php

namespace App\Http\Controllers;

use App\Models\UserSupport;
use Illuminate\Http\Request;

class ContactsController extends Controller
{
  /**
   * Shows the card for a given id.
   *
   * @return \Illuminate\Contracts\View\View
   */
  public function show()
  {
    return view('pages.contacts');
  }

  public function create(Request $request)
  {
    $validated = $request->validate([
      'email' => 'required|email',
      'name' => 'string',
      'subject' => 'required|string',
      'body' => 'required|string'
    ]);

    $support = new UserSupport();
    $support->email = $validated->input('email');
    $support->name = empty($validated->input('name')) ? "Anonymous" : $validated->input('name');
    $support->subject = $validated->input('subject');
    $support->body = $validated->input('body');
    $support->save();

    return response()->json($support);
  }
}
