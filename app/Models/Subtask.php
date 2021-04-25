<?php


namespace App\Models;


use Illuminate\Database\Eloquent\Model;

class Subtask extends Model
{
  public $timestamps = false;

  protected $table = 'subtask';

  protected $fillable = [
    'parent'
  ];

  public function parentTask()
  {
    return $this->belongsTo(Task::class, 'parent');
  }

  public function task()
  {
    return $this->belongsTo(Task::class, 'id');
  }
}
