<?php


namespace App\Models;


use Illuminate\Database\Eloquent\Model;

class CommentNotification extends Model
{
  public $timestamps = false;

  protected $table = 'comment_notification';

  protected $fillable = [
    'comment'
  ];

  public function notification()
  {
    return $this->belongsTo(Notification::class);
  }

  public function comment()
  {
    return $this->belongsTo(Comment::class, 'comment');
  }
}
