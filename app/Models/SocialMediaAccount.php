<?php


namespace App\Models;


use Illuminate\Database\Eloquent\Model;

class SocialMediaAccount extends Model
{
  public $timestamps = false;

  protected $table = 'social_media_account';

  protected $fillable = [
    'social_media', 'username', 'access_token'
  ];

  protected $hidden = [
    'access_token'
  ];

  public function client()
  {
    return $this->belongsToMany(AssociatedClientAccount::class, 'associated_client_account', 'account', 'client');
  }

  public function project()
  {
    return $this->belongsToMany(AssociatedProjectAccount::class, 'associated_project_account', 'account', 'project');
  }

}
