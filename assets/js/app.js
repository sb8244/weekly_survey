// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

import $ from 'jquery';
import ensureAnonymousSession from './services/session';
import { toDatetimeLocal } from './services/date';

ensureAnonymousSession().then((results) => {
  if (results.retrievalMethod === "jwt") {
    window.location.reload();
  }

  if (results.userInfo) {
    $(".user-info-box__name-link").text(results.userInfo.name);
    $(".user-info-box input[name='name']").val(results.userInfo.name);
    $(".add-discussion-link--okay").removeClass('hidden');
  } else if (results.userInfoForm) {
    $(".user-info-box__name-link").text("Enter your name");
    $(".add-discussion-link--prompt")
      .removeClass('hidden')
      .on("click", (e) => {
        e.stopPropagation();
        $(".user-info-box__name-link").click();
      });
  }
});

$(document.body).on('click', '.inline-form a', (e) => {
  e.preventDefault();

  const link = $(e.currentTarget);
  const form = link.parent().find('form');
  form.removeClass('hidden');
  link.addClass('hidden');
  form.find("input").focus();
});

$(document.body).on('click', '.inline-form-close', (e) => {
  e.preventDefault();

  const link = $(e.target).parents('.inline-form').find('a');
  const form = $(e.target).parents('.inline-form').find('form');
  form.addClass('hidden');
  link.removeClass('hidden');
});

// convert local datetime to UTC ISO string
$(document.body).on('change', 'form input[name="active_until_local"]', (e) => {
  const date = new Date(e.target.value);
  $(e.target).parents("form").find('input[name="active_until"]').val(date.toISOString());
});

// convert UTC ISO string to local datetime
$('form input[name="active_until"]').each((index, input) => {
  if (input.value) {
    const date = new Date(input.value);
    $(input).parents("form").find('input[name="active_until_local"]').val(toDatetimeLocal(date));
  }
});
