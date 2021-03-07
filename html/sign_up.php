<?php
    include_once('templates/tpl_common.php');
?>

<?php draw_header([], []); ?>

<div class="container d-flex flex-column justify-content-center my-5">
    <div class="row">
        <img src="images/oversee_blue_txt.svg" height="90" alt="company logo">
    </div>

    <div class="row justify-content-center mt-5">
        <div class="col-xl-4 col-lg-5 col-md-7">
            <div class="fs-2">Sign up</div>
            <div class="text-muted fs-5">Welcome to Oversee!</div>
            <div class="text-muted fs-5">Have an account already? <a href="sign_in.php" class="text-decoration-none" style="color: #00AFB9;">Sign in</a> instead.</div>
        </div>
    </div>

    <div class="row justify-content-center my-4">
        <div class="col-xl-4 col-lg-5 col-md-7">
            <form>
                <div class="mb-3">
                    <label for="inputEmail" class="form-label">Email</label>
                    <input type="email" class="form-control" id="inputEmail">
                </div>
                <div class="mb-3">
                    <label for="inputUsername" class="form-label">Username</label>
                    <input type="text" class="form-control" id="inputUsername">
                </div>
                <div class="mb-3">
                    <label for="inputPassword" class="form-label">Password</label>
                    <input type="password" class="form-control" id="inputPassword">
                </div>
                <div class="d-grid mt-4">
                    <!-- <button type="submit" class="btn btn-danger" style="background-color: #ea4c89;">Sign up</a> -->
                    <a href="dashboard.php" role="button" class="btn btn-danger" style="background-color: #ea4c89;">Sign up</a>
                </div>
            </form>
        </div>
    </div>

    <div class="row justify-content-center my-4">
        <div class="col-xl-4 col-lg-5 col-md-7">
            <div class="d-grid gap-2">
                <a href="#" role="button" class="btn btn-outline-secondary text-start"><i class="bi bi-google me-2"></i>Sign up with Google</a>
                <a href="#" role="button" class="btn btn-outline-secondary text-start"><i class="bi bi-facebook me-2"></i>Sign up with Facebook</a>
                <a href="#" role="button" class="btn btn-outline-secondary text-start"><i class="bi bi-twitter me-2"></i>Sign up with Twitter</a>
            </div>
        </div>
    </div>
</div>

<?php draw_footer(); ?>
