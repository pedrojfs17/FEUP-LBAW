<?php
    include_once('templates/tpl_common.php');
?>

<?php draw_header(["one-page-wonder.css"], ["script.js"]); ?>

<?php draw_landing_nav_bar() ?>

<header class="not-found masthead text-center text-main-color ">
  <div class="masthead-content">
    <section>
      <div class="container info">
        <div class="col-lg-12 order-lg-1">
              <div class="p-12">
              <img class="img-fluid" src="images/dolphin.png" width="600" alt="">
              </div>
          </div>
          <div class="col-lg-12 order-lg-2">
              <h5 class="display-1">404</h5>
              <h5>Ups, seems like you wandered into the wrong pond</h5>
          </div>
      </div>
    </section>
  </div>
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
