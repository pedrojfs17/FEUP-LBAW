<?php


namespace App\Models;


use Illuminate\Database\Eloquent\Model;

class CommentReply extends Model
{
  public $timestamps = false;

  protected $table = 'comment_reply';

  protected $fillable = [
    'parent'
  ];

  public function reply()
  {
    return $this->hasOne(Comment::class, 'id');
  }

  public function comment()
  {
    return $this->belongsTo(Comment::class, 'parent');
  }
}
