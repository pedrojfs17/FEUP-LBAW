<?php


namespace App\Models;


use Illuminate\Database\Eloquent\Model;

class Comment extends Model
{
  public $timestamps = false;

  protected $table = 'comment';

  protected $fillable = [
    'task', 'author', 'comment_date', 'comment_text'
  ];

  public function task()
  {
    return $this->belongsTo(Task::class, 'task');
  }

  public function author()
  {
    return $this->hasOne(Client::class, 'author');
  }

  public function replies()
  {
    return $this->hasMany(CommentReply::class, 'parent');
  }

  public function notification()
  {
    return $this->hasMany(CommentNotification::class, 'comment');
  }
}
