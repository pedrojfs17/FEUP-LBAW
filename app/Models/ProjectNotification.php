<?php


namespace App\Models;


use Illuminate\Database\Eloquent\Model;

class ProjectNotification extends Model
{
  public $timestamps = false;

  protected $table = 'project_notification';

  protected $fillable = [
    'project'
  ];

  public function notification()
  {
    return $this->belongsTo(Notification::class);
  }

  public function project()
  {
    return $this->belongsTo(Project::class, 'project');
  }
}
