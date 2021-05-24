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

  public function getReadableCommentDate() {
    return $this->humanTiming(strtotime($this->comment_date));
  }

  function humanTiming($time)
  {
    $time = time() - $time; // to get the time since that moment
    $time = ($time < 1) ? 1 : $time;
    $tokens = array (
      31536000 => 'year',
      2592000 => 'month',
      604800 => 'week',
      86400 => 'day',
      3600 => 'hour',
      60 => 'minute',
      1 => 'second'
    );

    foreach ($tokens as $unit => $text) {
      if ($time < $unit) continue;
      $numberOfUnits = floor($time / $unit);
      return $numberOfUnits.' '.$text.(($numberOfUnits>1)?'s':'');
    }

  }
}
