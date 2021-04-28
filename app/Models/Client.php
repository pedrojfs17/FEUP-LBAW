<?php


namespace App\Models;


class Client extends Account
{
  // Don't add create and update timestamps in database.
  public $timestamps = false;

  protected $table = 'client';

  protected $fillable = [
    'id', 'fullname', 'company', 'avatar', 'client_gender',
    'allowNoti', 'inviteNoti', 'assignNoti', 'waitingNoti', 'commentNoti',
    'reportNoti', 'hideCompleted', 'simplifiedTasks', 'color', 'search'
  ];

  public function account()
  {
    return $this->belongsTo(Account::class);
  }

  public function country()
  {
    return $this->belongsTo(Country::class, 'country');
  }

  public function reporter()
  {
    return $this->hasMany(Report::class, 'reporter');
  }

  public function reported()
  {
    return $this->hasMany(Report::class, 'reported');
  }

  public function notifications()
  {
    return $this->hasMany(Notification::class, 'client');
  }

  public function comments()
  {
    return $this->hasMany(Comment::class, 'author');
  }

  public function tasks()
  {
    return $this->belongsToMany(Task::class, 'assignment', 'client', 'task');
  }

  public function projects()
  {
    return $this->belongsToMany(Project::class, 'team_member', 'client_id', 'project_id')->withPivot('member_role');
  }

  public function socialMediaAccounts()
  {
    return $this->belongsToMany(SocialMediaAccount::class, 'associated_client_account', 'client', 'account');
  }

  public function invites()
  {
    return $this->belongsToMany(Project::class, 'invite', 'client_id', 'project_id')->withPivot('decision');
  }


}
