<?php


namespace App\Models;


use Illuminate\Database\Eloquent\Model;

class WaitingOn extends Model
{
    public $timestamps=false;

    protected $table='waiting_on';

    protected $fillable = [
      'task1','task2'
    ];

    protected $primaryKey = ['task1','task2'];

    public function task1() {
        return $this->hasOne(Task::class,'task1');
    }

    public function task2() {
        return $this->hasOne(Task::class,'task2');
    }
}
