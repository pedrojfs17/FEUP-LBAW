<?php


namespace App\Models;


use Illuminate\Database\Eloquent\Model;

class Project extends Model
{
  protected $table = 'project';

  public $timestamps = false;

  //CURRENT_DATE AND UPDATE_DATE USEFUL?

  protected $fillable = [
    'name', 'description', 'due_date',
  ];

  public function teamMembers()
  {
    return $this->belongsToMany(Client::class, 'team_member', 'project_id', 'client_id')->withPivot('member_role');
  }

  public function tasks()
  {
    return $this->hasMany(Task::class, 'project');
  }

  public function tags()
  {
    return $this->hasMany(Tag::class, 'project');
  }

  public function invites()
  {
    return $this->belongsToMany(Client::class, 'invite', 'project_id', 'client_id')->withPivot('decision');
  }

  public function socialMediaAccounts()
  {
    return $this->belongsToMany(SocialMediaAccount::class, 'associated_project_account', 'project', 'account');
  }

  public function notifications()
  {
    return $this->hasMany(ProjectNotification::class, 'project');
  }
}
