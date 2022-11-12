import React from 'react';


function Upperbar() {
  const sameTab = url => {
    window.open(url, '_self', 'noopener,noreferrer');
  };

  return (
    <div id='upperbar'>
      <div id='heading' onClick={() => sameTab('http://127.0.0.1:3000/')}> 
          <a href="http://127.0.0.1:3000/" target="_self" rel="noopener noreferrer"> BERLIN CITY VOTING SYSTEM </a> 
      </div>
    </div> 
  )
}

export default Upperbar;