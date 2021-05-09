<?php

namespace App\Models;

use Illuminate\Notifications\Notifiable;
use Illuminate\Foundation\Auth\User as Authenticatable;

class Account extends Authenticatable
{
  use Notifiable;

  // Don't add create and update timestamps in database.
  public $timestamps = false;

  protected $table = 'account';

  /**
   * The attributes that are mass assignable.
   *
   * @var array
   */
  protected $fillable = [
    'username', 'password', 'email', 'is_admin'
  ];

  /**
   * The attributes that should be hidden for arrays.
   *
   * @var array
   */
  protected $hidden = [
    'password'
  ]; //IN THE FUTURE - REMEMBER TOKEN FOR STAYING LOGGED IN

  public function client()
  {
    return $this->hasOne(Client::class, 'id');
  }

}
