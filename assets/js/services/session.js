export default function ensureAnonymousSession() {
  return postData('/asession', {ug: localStorage.ug})
    .then(data => {
      const ret = {};

      if (data.ug) {
        localStorage.ug = data.ug;
      }

      if (!data.user_info.name) {
        ret.userInfoForm = true;
      }

      return ret;
    });
}

function postData(url, data) {
  const csrfToken = document.head.querySelector("[name='csrf_token']").content;

  // Default options are marked with *
  return fetch(url, {
    body: JSON.stringify(data), // must match 'Content-Type' header
    cache: 'no-cache', // *default, no-cache, reload, force-cache, only-if-cached
    credentials: 'same-origin', // include, same-origin, *omit
    headers: {
      'user-agent': 'Mozilla/4.0 MDN Example',
      'content-type': 'application/json',
      'X-CSRF-Token': csrfToken
    },
    method: 'POST', // *GET, POST, PUT, DELETE, etc.
    mode: 'cors', // no-cors, cors, *same-origin
    redirect: 'follow', // *manual, follow, error
    referrer: 'no-referrer', // *client, no-referrer
  })
  .then(response => response.json()) // parses response to JSON
}
