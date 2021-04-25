<?php

namespace App\Http\Controllers;

use App\Models\UserSupport;
use Illuminate\Http\Request;

class ContactsController extends Controller
{
  /**
   * Shows the card for a given id.
   *
   * @return Response
   */
  public function show()
  {
    return view('pages.contacts');
  }

  public function create(Request $request)
  {
    if (!Auth::check()) return redirect('login');

    $validated = $request->validate([
      'email' => 'required|email',
      'name' => 'string',
      'subject' => 'required|string',
      'body' => 'required|string'
    ]);

    $support = new UserSupport();
    $this->authorize('create', $support);
    $support->email = $validated->input('email');
    $support->name = empty($validated->input('name')) ? "Anonymous" : $validated->input('name');
    $support->subject = $validated->input('subject');
    $support->body = $validated->input('body');
    $support->save();

    return $support;
  }
}
