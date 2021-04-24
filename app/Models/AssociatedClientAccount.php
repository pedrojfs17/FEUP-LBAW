<?php


namespace App\Models;


use Illuminate\Database\Eloquent\Model;

class AssociatedClientAccount extends Model
{
    public $timestamps =false;

    protected $table = 'associated_client_account';

    protected $fillable = [
      'account','client'
    ];

    protected $primaryKey = ['account','client'];

    public function account() {
        return $this->hasOne(Account::class,'account');
    }

    public function client() {
        return $this->hasOne(Client::class,'client');
    }
}
