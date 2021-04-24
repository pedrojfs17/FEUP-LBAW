<?php


namespace App\Models;


use Illuminate\Database\Eloquent\Model;

class Invite extends Model
{
    public $timestamps=false;

    protected $table='invite';

    protected $fillable = [
        'client_id','project_id','decision'
    ];

    protected $primaryKey = ['client_id','project_id'];

    public function client() {
        return $this->hasOne(Client::class,'client_id');
    }

    public function project() {
        return $this->hasOne(Project::class,'project_id');
    }


}
