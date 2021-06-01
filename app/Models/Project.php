<?php


namespace App\Models;


use Illuminate\Database\Eloquent\Model;

class Project extends Model
{
  protected $table = 'project';

  public $timestamps = false;

  //CURRENT_DATE AND UPDATE_DATE USEFUL?

  protected $fillable = [
    'name', 'description', 'due_date', 'closed'
  ];

  protected $appends = ['completion'];

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

  public function getMemberCount()
  {
    return count($this->teamMembers);
  }

  public function getReadableDueDate()
  {
    if ($this->due_date != null) {
      return date("D, j M Y", strtotime($this->due_date));
    }
    return null;
  }

  public function getCompletionAttribute()
  {
    if (count($this->tasks) > 0)
      return intdiv(count($this->tasks->where('task_status', 'Completed')) * 100, count($this->tasks));
    else return 0;
  }

  public function shiftPermissions(){
    if(count($this->teamMembers()->wherePivot('member_role','Owner')->get()) > 1) {
      return;
    }

    $editors = $this->teamMembers()->wherePivot('member_role','Editor')->get();
    if(count($editors) > 0) {
      foreach ($editors as $editor) {
        $this->teamMembers()->updateExistingPivot($editor->id, ['member_role' => 'Owner']);
      }
      $this->save();
      return;
    }

    $readers = $this->teamMembers()->wherePivot('member_role','Reader')->get();
    if(count($readers) > 0) {
      foreach ($readers as $reader) {
        $this->teamMembers()->updateExistingPivot($reader->id, ['member_role' => 'Owner']);
      }
      $this->save();
    }

  }
}
