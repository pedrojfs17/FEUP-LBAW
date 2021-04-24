<?php


namespace App\Models;


use Illuminate\Database\Eloquent\Model;

class ContainsTag extends Model
{
    public $timestamps = false;

    protected $table = 'contains_tag';

    protected $fillable = [
        'tag','task'
    ];

    protected $primaryKey = ['tag','task'];

    public function tag() {
        return $this->hasOne(Tag::class,'tag');
    }

    public function task() {
        return $this->hasOne(Task::class,'task');
    }
}
