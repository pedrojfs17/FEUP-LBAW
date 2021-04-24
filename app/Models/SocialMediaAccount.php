<?php


namespace App\Models;


use Illuminate\Database\Eloquent\Model;

class SocialMediaAccount extends Model
{
    public $timestamps =false;

    protected $table='social_media_account';

    protected $fillable = [
      'social_media','username','access_token'
    ];

    protected $hidden = [
      'access_token'
    ];

}
