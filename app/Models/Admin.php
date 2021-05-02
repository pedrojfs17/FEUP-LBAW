<?php


namespace App\Models;


use Illuminate\Database\Eloquent\Model;

class Admin extends Model
{
  // Don't add create and update timestamps in database.
  public $timestamps = false;

  protected $table = 'admin';

  protected $fillable = ['id'];

  public function account()
  {
    return $this->belongsTo(Account::class, 'id');
  }
}
