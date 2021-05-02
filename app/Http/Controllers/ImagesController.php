<?php

namespace App\Http\Controllers;


use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ImagesController extends Controller
{
  /**
   * Shows an avatar.
   *
   * @return string
   */
  public function show(Request $request, $img)
  {
    return Storage::get('avatars/' . $img);
  }
}
