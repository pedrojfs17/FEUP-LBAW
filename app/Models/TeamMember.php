<?php


namespace App\Models;


use Illuminate\Database\Eloquent\Model;

class TeamMember extends Model
{
    public $timestamps = false;

    protected $table = 'team_member';

    protected $fillable = [
        'client_id','project_id','member_role'
    ];

    protected $primaryKey = ['client_id','project_id'];

    public function client() {
        return $this->hasOne(Client::class,'client_id');
    }
    public function project() {
        return $this->hasOne(Project::class,'project_id');
    }

}
