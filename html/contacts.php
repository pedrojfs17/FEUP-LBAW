<?php
    include_once('templates/tpl_common.php');
?>

<?php draw_header(["one-page-wonder.css"], ["script.js"]); ?>
    
<?php draw_landing_nav_bar() ?>

<header class="masthead text-center text-white contacts">
    <div class="masthead-content">
        <section>
            <div class="container info">
                <div class="row align-items-center">
                    <div class="col-lg-6">
                        <div class="p-5">
                            <h2 class="display-4">Contact Us</h2>
                            <form>
                                <label for="nameInput" class="form-label">Name</label>
                                <div class="input-group mb-3">
                                    <input type="text" placeholder="Pedro Jorge" class="form-control" id="nameInput">
                                </div>

                                <label for="emailInput" class="form-label">Email</label>
                                <div class="input-group mb-3">
                                    <input type="email" placeholder="pmfriend98@gmail.com" class="form-control" id="emailInput">
                                </div>

                                <label for="nameInput" class="form-label">Subject</label>
                                <div class="input-group mb-3">
                                    <input type="text" placeholder="" class="form-control" id="subjectInput">
                                </div>

                                <label for="companyInput" class="form-label">How can we help?</label>
                                <div class="input-group mb-3">
                                    <textarea placeholder="" class="form-control" id="textInput" rows="4" cols="50"></textarea>
                                </div>
                                <button class="btn btn-primary btn-xl rounded-pill mt-5" type="button" id="button-editCompany">Send Request</button>
                            </form>
                        </div>
                    </div>
                    <div class="col-lg-6">
                        <div class="row align-items-center">
                            <div class="col-lg-6 order-lg-1">
                                <div class="p-5 contact">
                                    <img class="img-fluid rounded-circle" src="images/ab.jpg" width="150" alt="">
                                </div>
                            </div>
                            <div class="col-lg-6 order-lg-2">
                                <h5 class="display-6">António Bezerra</h5>
                                <h5>up201806854@fe.up.pt</h5>
                            </div>
                        </div>
                        <div class="row align-items-center">
                            <div class="col-lg-6 order-lg-1">
                                <div class="p-5 contact">
                                    <img class="img-fluid rounded-circle" src="images/ga.jpg" width="150" alt="">
                                </div>
                            </div>
                            <div class="col-lg-6 order-lg-2">
                                <h5 class="display-6">Gonçalo Alves</h5>
                                <h5>up201806451@fe.up.pt</h5>
                            </div>
                        </div>
                        <div class="row align-items-center">
                            <div class="col-lg-6 order-lg-1">
                                <div class="p-5 contact">
                                    <img class="img-fluid rounded-circle" src="images/is.jpg" width="150" alt="">
                                </div>
                            </div>
                            <div class="col-lg-6 order-lg-2">
                                <h5 class="display-6">Inês Silva</h5>
                                <h5>up201806385@fe.up.pt</h5>
                            </div>
                        </div>
                        <div class="row align-items-center">
                            <div class="col-lg-6 order-lg-1">
                                <div class="p-5 contact">
                                    <img class="img-fluid rounded-circle" src="images/ps.jpg" width="150" alt="">
                                </div>
                            </div>
                            <div class="col-lg-6 order-lg-2">
                                <h5 class="display-6">Pedro Seixas</h5>
                                <h5>up201806227@fe.up.pt</h5>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </div>
    <div class="bg-circle-1 bg-circle"></div>
    <div class="bg-circle-2 bg-circle"></div>
    <div class="bg-circle-3 bg-circle"></div>
    <div class="bg-circle-4 bg-circle"></div>
</header>


<?php draw_landing_footer(); ?>