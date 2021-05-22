<?php


namespace App\Models;


use Illuminate\Database\Eloquent\Model;

class Comment extends Model
{
  public $timestamps = false;

  protected $table = 'comment';

  protected $fillable = [
    'task', 'author', 'comment_date', 'comment_text', 'parent'
  ];

  public function task()
  {
    return $this->belongsTo(Task::class, 'task');
  }

  public function author()
  {
    return $this->belongsTo(Client::class, 'author');
  }

  public function replies()
  {
    return $this->hasMany(Comment::class, 'parent');
  }

  public function parent()
  {
    return $this->belongsTo(Comment::class, 'id');
  }

  public function notification()
  {
    return $this->hasMany(CommentNotification::class, 'comment');
  }
}
