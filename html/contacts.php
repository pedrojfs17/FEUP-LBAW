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


<!-- Site footer -->
<footer class="site-footer">
    <div class="container">
        <div class="row">
            <div class="col-sm-12 col-md-6">
                <h6>About</h6>
                <p class="text-justify">ZULUL</p>
            </div>

            <div class="col-xs-6 col-md-3 ms-auto mb-2 mb-lg-0">
                <h6>Contact Us</h6>
                <form class="form-inline">
                    <input class="mr-sm-2" type="search" placeholder="Search" aria-label="Search">
                    <button class="btn btn-outline-success my-2 my-sm-0" type="submit">Search</button>
                </form>
            </div>
        </div>
        <hr>
    </div>
    <div class="container me-auto">
        <div class="row">
            <div class="col-md-8 col-sm-6 col-xs-12">
                <p class="copyright-text">Copyright &copy; 2021 All Rights Reserved by
                    <a href="#">lbaw2134</a>.
                </p>
            </div>

            <div class="col-md-4 col-sm-6 col-xs-12">
                <ul class="social-icons">
                    <li><a class="facebook" href="#"><i class="fa fa-facebook"></i></a></li>
                    <li><a class="twitter" href="#"><i class="fa fa-twitter"></i></a></li>
                    <li><a class="dribbble" href="#"><i class="fa fa-dribbble"></i></a></li>
                    <li><a class="linkedin" href="#"><i class="fa fa-linkedin"></i></a></li>
                </ul>
            </div>
        </div>
    </div>
</footer>

<?php draw_footer(); ?>