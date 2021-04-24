<?php


namespace App\Models;


use Illuminate\Database\Eloquent\Model;

class CheckListItem extends Model
{
    public $timestamps = false;

    protected $table = 'check_list_item';

    protected $fillable = [
      'item_text','completed','task'
    ];

    public function task() {
        return $this->belongsTo(Task::class,'task');
    }
}
