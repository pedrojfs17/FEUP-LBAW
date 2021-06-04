<?php

namespace App\Http\Controllers;

use App\Models\Client;
use App\Models\Comment;
use App\Models\CheckListItem;
use App\Models\Project;
use App\Models\Task;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class TaskController extends Controller
{
  public function __construct()
  {
    $this->middleware('auth');
  }

  public function list(Request $request, Project $project)
  {
    $request->validate([
      'before_date' => 'nullable|date',
      'after_date' => 'nullable|date',
    ]);

    $this->authorize('showTasks', $project);

    $tags = $request->input('tag') == NULL ? NULL : explode(',',$request->input('tag'));
    $assignees =$request->input('assignees') == NULL ? NULL : explode(',',$request->input('assignees'));
    $beforeDate = $request->input('before_date');
    $afterDate = $request->input('after_date');

    $tasks = $project->tasks()
      ->when(!empty($tags), function ($query) use ($tags) {
        return $query->whereHas('tags', function ($q) use ($tags) {
          $q->whereIn('tag', $tags);
        });
      })
      ->when(!empty($assignees), function ($query) use ($assignees) {
        return $query->whereHas('assignees', function ($q) use ($assignees) {
          $q->whereIn('client', $assignees);
        });
      })
      ->when(!empty($beforeDate), function ($query) use ($beforeDate) {
        return $query->whereDate('due_date','<=',$beforeDate);
      })
      ->when(!empty($afterDate), function ($query) use ($afterDate) {
        return $query->whereDate('due_date','>=',$afterDate);
      })
      ->get()->sortBy('id');

    $view = view('partials.projectTasks', ['tasks' => $tasks])->render();
    return response()->json($view);
  }

  public function create(Request $request, Project $project)
  {
    $request->validate([
      'name' => 'required|string',
      'description' => 'nullable|string',
      'due_date' => 'nullable|date|after:today',
      'parent' => 'nullable|integer'
    ]);

    $this->authorize('createTask', $project);

    $task = new Task();
    $task->project = $project->id;

    $task->name = $request->input('name');
    if (!empty($request->input('description')))
      $task->description = $request->input('description');
    if (!empty($request->input('due_date')))
      $task->due_date = $request->input('due_date');
    if (!empty($request->input('parent'))) {
      $task->parent = $request->input('parent');
    }

    $task->save();

    $result = array(
      'taskCard' => view('partials.tasks.task', ['task' => Task::find($task->id)])->render(),
      'message' => view('partials.messages.successMessage', ['message' => 'Task created!'])->render()
    );

    return response()->json($result);
  }

  public function show(Project $project, Task $task)
  {
    $this->authorize('show', $task);

    $result = array();

    $result['taskId'] = $task->id;
    $result['taskCard'] = view('partials.tasks.task', ['task' => $task])->render();
    $result['taskModal'] = view('partials.tasks.taskModal', [
      'task' => $task,
      'user' => Client::find(Auth::user()->id),
      'role' => $project->teamMembers()->where('client_id', Auth::user()->id)->first()->pivot->member_role,
      ])->render();

    return response()->json($result);
  }

  public function update(Request $request, Project $project, Task $task)
  {
    $validator = Validator::make($request->all(), [
      'name' => 'string',
      'description' => 'string|nullable',
      'due_date' => "date|after:today|nullable",
      'task_status' => 'string'
    ], [
      'before' => 'The :attribute must be a date before ' . $project->getReadableDueDate() . '.'
    ]);
    $projdate = $project->due_date;
    $validator->sometimes('due_date', "before:$projdate", function ($input) use ($projdate) {
      return $projdate != null && $input->due_date != null;
    });
    if ($validator->fails()) {
      return response()->json(['errors' => $validator->messages()], Response::HTTP_BAD_REQUEST);
    }

    $this->authorize('updateTask', $project);

    if (!empty($request->input('name')))
      $task->name = $request->input('name');

    if ($request->has('description'))
      $task->description = $request->input('description');

    if ($request->has('due_date'))
      $task->due_date = $request->input('due_date');

    if (!empty($request->input('task_status')))
      $task->task_status = $request->input('task_status');

    $task->save();
    $task = Task::find($task->id);

    $result = array();
    $result['taskID'] = $task->id;
    $result['taskCard'] = view('partials.tasks.task', ['task' => $task])->render();
    $result['modalChanges'] = view('partials.tasks.taskModalInfo', [
      'task' => $task,
      'role' => $project->teamMembers()->where('client_id', Auth::user()->id)->first()->pivot->member_role])->render();
    $result['breadcrumbChanges'] = view('partials.tasks.taskModalBreadcrumb', ['task' => $task])->render();

    return response()->json($result);
  }

  public function delete(Project $project, Task $task)
  {
    $this->authorize('deleteTask', $project);
    $task->delete();
    return response()->json($task);
  }

  public function tag(Request $request, Project $project, Task $task)
  {
    $this->authorize('tag', $task);

    $request->validate([
      'tag' => 'nullable|string',
    ]);

    $task->tags()->detach();

    if(!empty($request->input('tag'))) {
      $tags = array_map('intval',explode(',',$request->input('tag')));
      foreach($tags as $tag) {
        $task->tags()->attach($tag);
      }
    }

    $task->save();

    $updatedTask = Task::find($task->id);
    $result = array();
    $result['taskID'] = $task->id;
    $result['taskCard'] = view('partials.tasks.task', ['task' => $updatedTask])->render();
    $result['modalChanges'] = view('partials.tasks.taskModalTags', ['task' => $updatedTask])->render();

    return response()->json($result);
  }

  public function subtask(Request $request, Project $project, Task $task)
  {
    $this->authorize('subtask', $task);

    $request->validate([
      'subtask' => 'nullable|string',
    ]);

    $subTasks = $project->tasks()->where('parent', $task->id)->get();
    foreach ($subTasks as $sub) {
      $subtaskObj = Task::find($sub->id);
      $subtaskObj->parent = null;
      $subtaskObj->save();
    }

    if(!empty($request->input('subtask'))) {
      $projectTasks = $project->tasks()->get()->map(function ($item, $key) {
        return $item->id;
      })->all();
      $subtask = array_map('intval', explode(',', $request->input('subtask')));
      foreach ($subtask as $sub) {
        if (!in_array($sub, $projectTasks)) continue;
        $subtaskObj = Task::find($sub);
        $subtaskObj->parent = $task->id;
        $subtaskObj->save();
      }
    }

    $updatedTask = Task::find($task->id);
    $result = array();
    $result['taskID'] = $task->id;
    $result['taskCard'] = view('partials.tasks.task', ['task' => $updatedTask])->render();
    $result['modalChanges'] = view('partials.tasks.taskModalSubtasks', ['task' => $updatedTask])->render();

    return response()->json($result);
  }

  public function waiting_on(Request $request, Project $project, Task $task)
  {
    $this->authorize('waiting_on', $task);

    $request->validate([
      'waiting' => 'nullable|string',
    ]);

    $task->waitingOn()->detach();
    if(!empty($request->input('waiting'))) {
      $waitingTasks = array_map('intval',explode(',',$request->input('waiting')));
      foreach($waitingTasks as $waiting) {
        $task->waitingOn()->attach($waiting);
      }
    }
    $task->save();

    $updatedTask = Task::find($task->id);
    $result = array();
    $result['taskID'] = $task->id;
    $result['taskCard'] = view('partials.tasks.task', ['task' => $updatedTask])->render();
    $result['modalChanges'] = view('partials.tasks.taskModalWaiting', ['task' => $updatedTask])->render();

    return response()->json($result);
  }

  public function assignment(Request $request, Project $project, Task $task)
  {
    $this->authorize('assignment', $task);

    $request->validate([
      'assign' => 'nullable|string',
    ]);

    $task->assignees()->detach();
    if(!empty($request->input('assign'))) {
      $assignees = array_map('intval',explode(',',$request->input('assign')));
      foreach($assignees as $assignee) {
        $task->assignees()->attach($assignee);
      }
    }
    $task->save();

    $updatedTask = Task::find($task->id);
    $result = array();
    $result['taskID'] = $task->id;
    $result['taskCard'] = view('partials.tasks.task', ['task' => $updatedTask])->render();
    $result['modalChanges'] = view('partials.tasks.taskModalAssign', ['task' => $updatedTask])->render();

    return response()->json($result);
  }

  public function comment(Request $request, Project $project, Task $task)
  {
    $this->authorize('comment', $task);

    $request->validate([
      'text' => 'string'
    ]);

    $comment = new Comment();
    $comment->task = $task->id;
    $comment->author = Auth::id();
    $comment->comment_date = date("Y-m-d H:i:s");
    $comment->comment_text = $request->input('text');

    if (!empty($request->input('parent'))) {
      $comment->parent = $request->input('parent');
      $comment->save();

      $result = view('partials.commentReply', ['reply' => Comment::find($comment->id)])->render();
      return response()->json($result);
    }

    $comment->save();
    $result = view('partials.comment', ['comment' => Comment::find($comment->id), 'task' => $task, 'user' => Client::find(Auth::user()->id)])->render();
    return response()->json($result);
  }

  public function createItem(Request $request, Project $project, Task $task)
  {
    $this->authorize('createCheckListItem', $task);

    $request->validate([
      'new_item' => 'required|string'
    ]);

    $item = new CheckListItem();
    $item->task = $task->id;
    $item->item_text = $request->input('new_item');
    $item->completed = false;
    $item->save();

    $result = array();
    $updatedTask = Task::find($task->id);
    $result['taskID'] = $task->id;
    $result['taskCard'] = view('partials.tasks.task', ['task' => $updatedTask])->render();
    $result['modalChanges'] = view('partials.tasks.taskModalChecklist', [
      'task' => $updatedTask,
      'role' => $project->teamMembers()->where('client_id', Auth::user()->id)->first()->pivot->member_role])->render();

    return response()->json($result);
  }

  public function updateItem(Request $request, Project $project, Task $task, CheckListItem $checklistitem)
  {
    $this->authorize('updateCheckListItem', $task);

    $request->validate([
      'completed' => 'required|string'
    ]);

    $checklistitem->completed = filter_var($request->input('completed'), FILTER_VALIDATE_BOOLEAN);
    $checklistitem->save();

    $updatedTask = Task::find($task->id);
    $result = array();
    $result['taskID'] = $task->id;
    $result['taskCard'] = view('partials.tasks.task', ['task' => $updatedTask])->render();
    $result['modalChanges'] = view('partials.tasks.taskModalChecklist', [
      'task' => $updatedTask,
      'role' => $project->teamMembers()->where('client_id', Auth::user()->id)->first()->pivot->member_role])->render();

    return response()->json($result);
  }

  public function deleteItem(Project $project, Task $task, CheckListItem $checklistitem)
  {
    $this->authorize('deleteCheckListItem', $task);
    $checklistitem->delete();
    $updatedTask = Task::find($task->id);
    $result = array();
    $result['taskID'] = $task->id;
    $result['taskCard'] = view('partials.tasks.task', ['task' => $updatedTask])->render();
    $result['modalChanges'] = view('partials.tasks.taskModalChecklist', [
      'task' => $updatedTask,
      'role' => $project->teamMembers()->where('client_id', Auth::user()->id)->first()->pivot->member_role])->render();

    return response()->json($result);
  }
}
