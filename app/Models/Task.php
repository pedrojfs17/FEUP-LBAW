<?php


namespace App\Models;


use Illuminate\Database\Eloquent\Model;

class Task extends Model
{
  public $timestamps = false;

  protected $table = 'task';

  protected $fillable = [
    'project', 'name', 'description', 'due_date', 'task_status', 'search', 'parent'
  ];

  public function hasParent() {
    return $this->getAttribute('parent') != null;
  }

  public function project()
  {
    return $this->belongsTo(Project::class, 'project');
  }

  public function subtasks()
  {
    return $this->hasMany(Task::class, 'parent','id');
  }

  public function parent()
  {
    return $this->belongsTo(Task::class, 'parent');
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
      if ($comment->parent == null) {
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

  public function getChecklistCompletion(): int
  {
    if (count($this->checkListItems) > 0)
      return intdiv(count($this->checklistItems->where('completed', true)) * 100, count($this->checklistItems));
    else return 0;
  }
}
