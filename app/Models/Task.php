<?php


namespace App\Models;


use Illuminate\Database\Eloquent\Model;

class Task extends Model
{
  public $timestamps = false;

  protected $table = 'task';

  protected $fillable = [
    'project', 'name', 'description', 'due_date', 'task_status', 'search'
  ];

  public function project()
  {
    return $this->belongsTo(Project::class, 'project');
  }

  public function subtasks()
  {
    return $this->hasMany(Subtask::class, 'parent');
  }

  public function parent()
  {
    return $this->belongsTo(Subtask::class, 'id');
  }

  public function waitingOn()
  {
    return $this->belongsToMany(Task::class, 'waiting_on', 'task1', 'task2');
  }

  public function hasWaiting()
  {
    return $this->belongsToMany(Task::class, 'waiting_on', 'task2', 'task1');
  }

  public function tags()
  {
    return $this->belongsToMany(Tag::class, 'contains_tag', 'task', 'tag');
  }

  public function assignees()
  {
    return $this->belongsToMany(Client::class, 'assignment', 'task', 'client');
  }

  public function checklistItems()
  {
    return $this->hasMany(CheckListItem::class, 'task');
  }

  public function comments()
  {
    return $this->hasMany(Comment::class, 'task');
  }

  public function notifications()
  {
    return $this->hasMany(AssignmentNotification::class, 'assignment');
  }

  public function getParentComments()
  {
    $parent_comments = array();
    $comments = $this->comments;
    foreach ($comments as $comment)
    {
      if (CommentReply::find($comment->id) == null) {
        array_push($parent_comments, $comment);
      }
    }
    return $parent_comments;
  }

  public function getReadableDueDate()
  {
    if ($this->due_date != null) {
      return date("D, j M Y", strtotime($this->due_date));
    }
    return null;
  }
}
