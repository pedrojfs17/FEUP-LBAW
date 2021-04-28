<?php


namespace App\Models;


class Admin extends Account
{
  // Don't add create and update timestamps in database.
  public $timestamps = false;

  protected $table = 'admin';

  protected $fillable = ['id'];

  public function account()
  {
    return $this->belongsTo(Account::class);
  }
}
