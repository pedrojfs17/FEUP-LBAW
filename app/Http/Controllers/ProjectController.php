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

  /**
   * Show the form for creating a new resource.
   *
   * @return \Illuminate\Http\RedirectResponse|\Illuminate\Routing\Redirector
   */
  public function create(Request $request)
  {
    $request->validate([
      'name' => 'required|string',
      'description' => 'required|string',
      'due_date' => 'date|after:today'
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
        $project->teamMembers()->attach($member, ['member_role' => 'Editor']);
    }
    return redirect(route('project.overview', ['id' => $project->id]));
  }

  /**
   * Display the specified resource.
   *
   * @param int $id
   * @param \Illuminate\Http\Request $request
   * @return \Illuminate\Http\JsonResponse
   */
  public function show(Request $request, $id)
  {
    $project = Project::find($id);
    $this->authorize('show', $project);
    return response()->json($project);
  }

  /**
   * Display the specified resource.
   *
   * @return \Illuminate\Contracts\Foundation\Application|\Illuminate\Contracts\View\Factory|\Illuminate\Contracts\View\View|\Illuminate\Http\JsonResponse
   */
  public function list(Request $request)
  {
    $client = Client::find(Auth::user()->id);

    $searchQuery = $request->input('query');
    $higherThanCompletion = $request->input('higher_completion');
    $lowerThanCompletion = $request->input('lower_completion');
    $beforeDate = $request->input('before_date');
    $afterDate = $request->input('after_date');

    $projects = $client->projects()
      ->when(!empty($searchQuery), function ($query) use ($searchQuery) {
        return $query->whereRaw('search @@ plainto_tsquery(\'english\', ?)', [$searchQuery])
          ->orderByRaw('ts_rank(search, plainto_tsquery(\'english\', ?)) DESC', [$searchQuery]);
      })
      ->when(!empty($beforeDate), function ($query) use ($beforeDate) {
        return $query->whereDate('due_date','<=',$beforeDate);
      })
      ->when(!empty($afterDate), function ($query) use ($afterDate) {
        return $query->whereDate('due_date','>=',$afterDate);
      })
      ->get()
      ->when(!empty($higherThanCompletion), function ($query) use ($higherThanCompletion) {
        return $query->where('completion','>=',intval($higherThanCompletion));
      })
      ->when(!empty($lowerThanCompletion), function ($query) use ($lowerThanCompletion) {
        return $query->where('completion','<=',intval($lowerThanCompletion));
      })
      ->sortByDesc('id');

    $page =  $request->input('page') ? intval($request->input('page')) : (Paginator::resolveCurrentPage() ?: 1);

    $paginator = new Paginator($projects->forPage($page, 5), $projects->count(), 5, $page);
    $paginator->setPath("/api/project");


    $view = view('partials.dashboardProjects', ['projects' => $paginator, 'pagination'=>true])->render();

    return response()->json($view);
  }

  /**
   * Update the specified resource in storage.
   *
   * @param \Illuminate\Http\Request $request
   * @param int $id
   * @return \Illuminate\Http\JsonResponse
   */
  public function update(Request $request, $id)
  {
    $request->validate([
      'name' => 'string',
      'description' => 'string',
      'due_date' => 'date|after:today'
    ]);

    $project = Project::find($id);
    $this->authorize('update', $project);

    if (!empty($request->input('name')))
      $project->name = $request->input('name');

    if (!empty($request->input('description')))
      $project->description = $request->input('description');

    if (!empty($request->input('due_date')))
      $project->due_date = $request->input('due_date');

    $project->save();

    return response()->json($project);
  }

  /**
   * Remove the specified resource from storage.
   *
   * @param \App\Models\Project $project
   * @return
   */
  public function delete(Request $request, $id)
  {
    $project = Project::find($id);
    $this->authorize('delete', $project);
    $project->teamMembers()->wherePivot('member_role', '!=', 'Owner')->detach();
    $project->delete();
    return redirect('dashboard')->with('message', 'Successfully deleted project: ' . $project->name);
  }

  public function editMember(Request $request, $id, $username)
  {
    $request->validate([
      'member_role' => ['required', Rule::in(['Reader', 'Editor', 'Owner']),]
    ]);

    $project = Project::find($id);
    $account = Account::where('username', '=', $username)->first();

    $this->authorize('changePermissions', $project);

    $project->teamMembers()->updateExistingPivot($account->id, ['member_role' => $request->input('member_role')]);
    $member = $project->teamMembers()->where('client_id', '=', $account->id)->first();
    $message = $username . " is now " . $request->input('member_role') . "!";

    $results = array();
    $results['message'] = view('partials.successMessage', ['message' => $message])->render();
    $results['member'] = array(
      'username' => $username,
      'role' => view('partials.memberRoleIcon', ['member' => $member])->render()
    );

    return response()->json($results);
  }

  /**
   * Display the specified resource.
   *
   * @param \Illuminate\Http\Request $request
   * @param int $id
   * @return \Illuminate\Contracts\Foundation\Application|\Illuminate\Http\JsonResponse|\Illuminate\Http\RedirectResponse|\Illuminate\Routing\Redirector
   */
  public function leave(Request $request, $id, $username)
  {
    $project = Project::find($id);
    $account = Account::where('username', '=', $username)->first();

    $this->authorize('leave', [$project, $account]);

    $member = $project->teamMembers()->wherePivot('client_id', '=', $account->id);
    $member->detach();

    if (Auth::user()->id == $account->id)
      return redirect('dashboard');
    else {
      $results = array('message' => view('partials.successMessage', ['message' => "Deleted member " . $username . "!"])->render());
      return response()->json($results);
    }
  }

  /**
   * Display the specified resource.
   *
   * @param \Illuminate\Http\Request $request
   * @param int $id
   * @return \Illuminate\Contracts\Foundation\Application|\Illuminate\Contracts\View\Factory|\Illuminate\Contracts\View\View|Response
   */
  public function preferences(Request $request, $id)
  {
    $project = Project::find($id);
    if ($project == null) return view('errors.404');
    $this->authorize('preferences', $project);
    return view('pages.preferences', [
      'project' => $project,
      'role' => $project->teamMembers()->where('client_id', Auth::user()->id)->first()->pivot->member_role,
      'user' => Client::find(Auth::user()->id)
    ]);
  }

  /**
   * Display the specified resource.
   *
   * @param \Illuminate\Http\Request $request
   * @param int $id
   * @return \Illuminate\Contracts\Foundation\Application|\Illuminate\Contracts\View\Factory|\Illuminate\Contracts\View\View|Response
   */
  public function assignments(Request $request, $id)
  {
    $project = Project::find($id);
    if ($project == null) return view('errors.404');
    $this->authorize('assignments', $project);
    return view('pages.assignments', [
      'tasks' => $project->tasks()->get()->sortBy('id'),
      'project' => $project,
      'role' => $project->teamMembers()->where('client_id', Auth::user()->id)->first()->pivot->member_role,
      'user' => Client::find(Auth::user()->id)
    ]);
  }

  /**
   * Display the specified resource.
   *
   * @param \Illuminate\Http\Request $request
   * @param int $id
   * @return \Illuminate\Contracts\Foundation\Application|\Illuminate\Contracts\View\Factory|\Illuminate\Contracts\View\View|Response
   */
  public function status(Request $request, $id)
  {
    $project = Project::find($id);
    if ($project == null) return view('errors.404');
    $this->authorize('status_board', $project);
    return view('pages.status_board', [
      'tasks' => $project->tasks()->get()->sortBy('id'),
      'project' => $project,
      'role' => $project->teamMembers()->where('client_id', Auth::user()->id)->first()->pivot->member_role,
      'user' => Client::find(Auth::user()->id),
      'status_enum' => ["Not Started", 'Waiting', "In Progress", "Completed"]
    ]);
  }

  /**
   * Display the specified resource.
   *
   * @param \Illuminate\Http\Request $request
   * @param int $id
   * @return \Illuminate\Contracts\Foundation\Application|\Illuminate\Contracts\View\Factory|\Illuminate\Contracts\View\View|Response
   */
  public function statistics(Request $request, $id)
  {
    $project = Project::find($id);
    if ($project == null) return view('errors.404');
    $this->authorize('statistics', $project);
    return view('pages.statistics', [
      'project' => $project,
      'role' => $project->teamMembers()->where('client_id', Auth::user()->id)->first()->pivot->member_role,
      'user' => Client::find(Auth::user()->id)
    ]);
  }

  /**
   * Display the specified resource.
   *
   * @param \Illuminate\Http\Request $request
   * @param int $id
   * @return \Illuminate\Contracts\Foundation\Application|\Illuminate\Contracts\View\Factory|\Illuminate\Contracts\View\View|Response
   */
  public function overview(Request $request, $id)
  {
    $project = Project::find($id);
    if ($project == null) return view('errors.404');
    $this->authorize('overview', $project);
    return view('pages.overview', [
      'tasks' => $project->tasks()->get()->sortBy('id'),
      'project' => $project,
      'role' => $project->teamMembers()->where('client_id', Auth::user()->id)->first()->pivot->member_role,
      'user' => Client::find(Auth::user()->id)
    ]);
  }

  /**
   * Display the specified resource.
   *
   * @param \Illuminate\Http\Request $request
   * @param int $id
   * @return \Illuminate\Contracts\Foundation\Application|\Illuminate\Contracts\View\Factory|\Illuminate\Contracts\View\View|Response
   */
  public function invite(Request $request, $id)
  {
    $project = Project::find($id);
    $this->authorize('invite', $project);
    $project->invites()->attach($request->client);
    return view('pages.overview', ['overview' => $project->tasks()]);
  }

  /**
   * Display the specified resource.
   *
   * @param \Illuminate\Http\Request $request
   * @param int $id
   * @return \Illuminate\Contracts\Foundation\Application|\Illuminate\Contracts\View\Factory|\Illuminate\Contracts\View\View|Response
   */
  public function updateInvite(Request $request, $id, $invite_id)
  {
    $project = Project::find($id);
    $request->validate([
      'decision' => 'required|boolean',
    ]);
    $this->authorize('updateInvite', $project);
    $project->invites()->updateExistingPivot($invite_id, [
      'decision' => $request->decision
    ]);
    return view('pages.overview', ['overview' => $project->tasks()]);
  }
}
