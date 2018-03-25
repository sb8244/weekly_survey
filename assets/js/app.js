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

ensureAnonymousSession();

$(document.body).on('click', '.inline-form a', (e) => {
  e.preventDefault();

  const link = $(e.target);
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
