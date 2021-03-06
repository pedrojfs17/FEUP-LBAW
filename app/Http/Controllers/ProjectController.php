<?php

namespace App\Http\Controllers;

use App\Models\Account;
use App\Models\Client;
use App\Models\Project;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Auth;
use Illuminate\Pagination\LengthAwarePaginator as Paginator;
use Illuminate\Validation\Rule;

class ProjectController extends Controller
{

  public function __construct()
  {
    $this->middleware('auth');
  }

  public function create(Request $request)
  {
    $request->validate([
      'name' => 'required|string',
      'description' => 'required|string',
      'due_date' => 'date|after:today|nullable'
    ]);

    $project = new Project();
    $project->name = $request->input('name');
    $project->description = $request->input('description');
    if (!empty($request->input('due_date')))
      $project->due_date = $request->input('due_date');
    $project->save();

    $project->teamMembers()->attach(Auth::User()->id, ['member_role' => 'Owner']);
    $members = $request->input('members');
    if ($members != null) {
      foreach ($request->input('members') as $member)
        $project->invites()->attach($member);
    }
    return redirect(route('project.overview', ['project' => $project->id]))->with(['message' => 'Created Project!', 'message-type' => 'Success']);
  }

  public function show(Project $project)
  {
    $this->authorize('show', $project);
    return response()->json($project);
  }

  public function list(Request $request)
  {
    $client = Client::find(Auth::user()->id);

    $searchQuery = $request->input('query');
    $higherThanCompletion = $request->input('higher_completion');
    $lowerThanCompletion = $request->input('lower_completion');
    $beforeDate = $request->input('before_date');
    $afterDate = $request->input('after_date');
    $closed = $request->input('closed');

    $projects = $client->projects()
      ->when($searchQuery !== null, function ($query) use ($searchQuery) {
        return $query->whereRaw('search @@ plainto_tsquery(\'english\', ?)', [$searchQuery])
          ->orderByRaw('ts_rank(search, plainto_tsquery(\'english\', ?)) DESC', [$searchQuery]);
      })
      ->when(!empty($beforeDate), function ($query) use ($beforeDate) {
        return $query->whereDate('due_date','<=',$beforeDate);
      })
      ->when(!empty($afterDate), function ($query) use ($afterDate) {
        return $query->whereDate('due_date','>=',$afterDate);
      })
      ->when($closed !== null, function ($query) use ($closed) {
        return $query->where('closed', $closed);
      })
      ->get()
      ->when($higherThanCompletion !== null, function ($query) use ($higherThanCompletion) {
        return $query->where('completion','>=',intval($higherThanCompletion));
      })
      ->when($lowerThanCompletion !== null, function ($query) use ($lowerThanCompletion) {
        return $query->where('completion','<=',intval($lowerThanCompletion));
      })->sortByDesc('id')->sortBy('closed');

    $page = $request->input('page') ? intval($request->input('page')) : (Paginator::resolveCurrentPage() ?: 1);

    $paginator = new Paginator($projects->forPage($page, 5), $projects->count(), 5, $page);
    $paginator->setPath("/api/project");

    $view = view('partials.dashboardProjects', ['projects' => $paginator, 'pagination'=>true])->render();

    return response()->json($view);
  }

  public function update(Request $request, Project $project)
  {
    $request->validate([
      'name' => 'string',
      'description' => 'string',
      'due_date' => 'date|after:today|nullable',
      'closed' => 'boolean'
    ]);

    $this->authorize('update', $project);

    if (!empty($request->input('name')))
      $project->name = $request->input('name');

    if ($request->has('description'))
      $project->description = $request->input('description');

    if ($request->has('due_date'))
      $project->due_date = $request->input('due_date');

    if($request->has('closed'))
      $project->closed = $request->input('closed');

    $project->save();

    $response = array();

    $response['id'] = $project->id;
    $response['name'] = $project->name;
    $response['projStatus'] = view('partials.project.projectStatus', ['project' => $project])->render();

    return response()->json($response);
  }

  public function delete(Project $project)
  {
    $this->authorize('delete', $project);
    $project->teamMembers()->wherePivot('member_role', '!=', 'Owner')->detach();
    $project->delete();
    return redirect('dashboard')->with(['message' => 'Deleted project: ' . $project->name, 'message-type' => 'Success']);
  }

  public function editMember(Request $request, Project $project, $username)
  {
    $request->validate([
      'member_role' => ['required', Rule::in(['Reader', 'Editor', 'Owner']),]
    ]);

    $account = Account::where('username', '=', $username)->first();

    $this->authorize('changePermissions', $project);

    $project->teamMembers()->updateExistingPivot($account->id, ['member_role' => $request->input('member_role')]);
    $member = $project->teamMembers()->where('client_id', '=', $account->id)->first();
    $message = $username . " is now " . $request->input('member_role') . "!";

    $results = array();
    $results['message'] = view('partials.messages.successMessage', ['message' => $message])->render();
    $results['member'] = array(
      'username' => $username,
      'role' => view('partials.project.memberRoleIcon', ['member' => $member])->render()
    );

    return response()->json($results);
  }

  public function leave(Project $project, $username)
  {
    $account = Account::where('username', '=', $username)->first();

    $this->authorize('leave', [$project, $account]);

    $member = $project->teamMembers()->wherePivot('client_id', '=', $account->id);
    $member->detach();

    if (Auth::user()->id == $account->id)
      return redirect('dashboard')->with(['message' => 'Left project: ' . $project->name, 'message-type' => 'Success']);
    else {
      $results = array('message' => view('partials.messages.successMessage', ['message' => "Deleted member " . $username . "!"])->render());
      return response()->json($results);
    }
  }

  public function invite(Request $request, Project $project)
  {
    $client = Client::find($request->client);
    $this->authorize('invite', [$project, $client]);
    $project->invites()->attach($client->id);
    return view('pages.overview', [
      'tasks' => $project->tasks()->get()->reverse(),
      'project' => $project,
      'role' => $project->teamMembers()->where('client_id', Auth::user()->id)->first()->pivot->member_role,
      'user' => Client::find(Auth::user()->id)]);
  }

  public function updateInvite(Request $request, Project $project, $invite)
  {
    $request->validate([
      'decision' => 'required|boolean',
    ]);
    $this->authorize('updateInvite', [$project, $request->decision]);
    $project->invites()->updateExistingPivot($invite, [
      'decision' => $request->decision
    ]);
    return response()->json(array());
  }

  public function overview(Project $project)
  {
    $this->authorize('overview', $project);
    return view('pages.overview', [
      'tasks' => $project->tasks()->get()->sortBy('id'),
      'project' => $project,
      'role' => $project->teamMembers()->where('client_id', Auth::user()->id)->first()->pivot->member_role,
      'user' => Client::find(Auth::user()->id)
    ]);
  }

  public function status(Project $project)
  {
    $this->authorize('status_board', $project);
    return view('pages.status_board', [
      'tasks' => $project->tasks()->get()->sortBy('id'),
      'project' => $project,
      'role' => $project->teamMembers()->where('client_id', Auth::user()->id)->first()->pivot->member_role,
      'user' => Client::find(Auth::user()->id),
      'status_enum' => ["Not Started", 'Waiting', "In Progress", "Completed"]
    ]);
  }

  public function assignments(Project $project)
  {
    $this->authorize('assignments', $project);
    return view('pages.assignments', [
      'tasks' => $project->tasks()->get()->sortBy('id'),
      'project' => $project,
      'role' => $project->teamMembers()->where('client_id', Auth::user()->id)->first()->pivot->member_role,
      'user' => Client::find(Auth::user()->id)
    ]);
  }

  public function preferences(Project $project)
  {
    $this->authorize('preferences', $project);

    $members = $project->teamMembers()->where('client_id', Auth::id())->get();
    $members = $members->merge($project->teamMembers()->wherePivot('member_role', 'Owner')->get());
    $members = $members->merge($project->teamMembers()->wherePivot('member_role', 'Editor')->get());
    $members = $members->merge($project->teamMembers()->wherePivot('member_role', 'Reader')->get());

    return view('pages.preferences', [
      'project' => $project,
      'members' => $members,
      'role' => $project->teamMembers()->where('client_id', Auth::user()->id)->first()->pivot->member_role,
      'user' => Client::find(Auth::user()->id)
    ]);
  }

  public function statistics(Project $project)
  {
    $this->authorize('statistics', $project);
    return view('pages.statistics', [
      'project' => $project,
      'role' => $project->teamMembers()->where('client_id', Auth::user()->id)->first()->pivot->member_role,
      'user' => Client::find(Auth::user()->id)
    ]);
  }
}
