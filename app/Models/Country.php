<?php


namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Country extends Model
{

  // Don't add create and update timestamps in database.
  public $timestamps = false;

  protected $table = 'country';

  protected $fillable = [
    'iso', 'name'
  ];

  public function client()
  {
    return $this->belongsTo(Client::class, 'country');
  }
}
