export default function ensureAnonymousSession() {
  postData('/asession', {ug: localStorage.ug})
    .then(data => {
      if (data.ug) {
        localStorage.ug = data.ug;
      }
    })
    .catch(error => console.error(error))
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
