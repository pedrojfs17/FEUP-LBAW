<?php


namespace App\Models;


use Illuminate\Database\Eloquent\Model;

class Tag extends Model
{
  public $timestamps = false;

  protected $table = 'tag';

  protected $fillable = [
    'project', 'name', 'color'
  ];

  public function project()
  {
    return $this->belongsTo(Project::class, 'project');
  }

  public function tasks()
  {
    return $this->belongsToMany(Task::class, 'contains_tag', 'tag', 'task');
  }
}
