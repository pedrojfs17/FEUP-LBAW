<?php

namespace App\Http\Controllers;

use App\Models\Client;
use App\Models\Project;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Auth;

class ProjectController extends Controller
{

  public function __construct()
  {
    $this->middleware('auth');
  }

  /**
   * Show the form for creating a new resource.
   *
   * @return \Illuminate\Http\JsonResponse
   */
  public function create(Request $request)
  {
    $validated = $request->validate([
      'name' => 'required|string',
      'description' => 'required|string',
      'due_date' => 'integer'
    ]);

    $project = new Project();
    $project->name = $validated->input('name');
    $project->description = $validated->input('description');
    if (!empty($validated->input('due_date')))
      $project->due_date = $validated->input('due_date');
    $project->save();

    return response()->json($project);
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
   * @return \Illuminate\Http\JsonResponse
   */
  public function list()
  {
    $projects = Client::find(Auth::user()->id)->projects()->orderBy('id')->get();
    return response()->json($projects);
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
    $validated = $request->validate([
      'name' => 'string',
      'description' => 'string',
      'due_date' => 'integer'
    ]);

    $project = Project::find($id);
    $this->authorize('update', $project);
    $project->name = empty($validated->input('name')) ? $project->name : $validated->input('name');
    $project->description = empty($validated->input('description')) ? $project->description : $validated->input('description');
    $project->due_date = empty($validated->input('due_date')) ? $project->due_date : $validated->input('due_date');
    $project->save();

    return response()->json($project);
  }

  /**
   * Remove the specified resource from storage.
   *
   * @param \App\Models\Project $project
   * @return \Illuminate\Http\JsonResponse
   */
  public function delete(Request $request, $id)
  {
    $project = Project::find($id);
    $this->authorize('delete', $project);
    $project->delete();
    return response()->json($project);
  }

  /**
   * Display the specified resource.
   *
   * @param \Illuminate\Http\Request $request
   * @param int $id
   * @return \Illuminate\Contracts\Foundation\Application|\Illuminate\Http\RedirectResponse|Response|\Illuminate\Routing\Redirector
   */
  public function leave(Request $request, $id)
  {
    $project = Project::find($id);

    $this->authorize('leave', $project);

    $team_member = $project->teamMembers()::find(Auth::user()->id);
    $team_member->delete();

    return redirect('pages.dashboard');
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
    $this->authorize('preferences', $project);
    return view('pages.preferences', ['project' => $project]);
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
    $this->authorize('assignments', $project);
    return view('pages.assignments', ['assignments' => $project->assignments()]);
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
    $this->authorize('status_board', $project);
    return view('pages.status_board', ['status_board' => $project->tasks()]);
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
    $this->authorize('statistics', $project);
    return view('pages.statistics', ['project' => $project]);
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
    $this->authorize('overview', $project);
    return view('pages.overview', ['tasks' => $project->tasks()->get(), 'project' => $project]);
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
    $validated = $request->validate([
      'decision' => 'required|boolean',
    ]);
    $this->authorize('updateInvite', $project);
    $project->invites()->updateExistingPivot($invite_id, [
      'decision' => $validated->decision
    ]);
    return view('pages.overview', ['overview' => $project->tasks()]);
  }
}
