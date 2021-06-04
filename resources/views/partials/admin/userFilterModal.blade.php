<div class="modal fade" id="userFilterModal" tabindex="-1" aria-labelledby="usersFilterModalLabel"
     aria-hidden="true">
  <div class="modal-dialog modal-lg">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">User Filters</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <form data-id="userFilter" id="userFilter" data-href="/profile">
          <label for="genderSelection">Gender</label>
          <select class="form-control tag-selection" multiple="multiple" name="gender" id="genderSelection">
            <option value="Female">Female</option>
            <option value="Male">Male</option>
            <option value="Unspecified">Unspecified</option>
          </select>

          <label for="countrySelection">Country</label>
          <select class="form-control tag-selection" multiple="multiple" name="country" id="countrySelection">
            @foreach ($countries as $country)
              <option value="{{$country->id}}">{{$country->name}}</option>
            @endforeach
          </select>

          <button type="submit" class="d-none"></button>
        </form>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-success" data-bs-dismiss="modal" id="userFilterSubmit">Filter</button>
      </div>
    </div>
  </div>
</div>

