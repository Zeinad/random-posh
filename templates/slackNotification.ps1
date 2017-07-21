Function template {
try{
  #set up your notification info
  $SlackToken = "yourSlackToken"
  $SlackChannel = "@yourSlackUserOr#yourSlackChannel"
  $SlackBotUserName = "zbot"

  #do the stuff here

  #once stuff is complete
  #set up to let yourself know how cool this is and that everything went well
  $postSlackMessage = @{token=$SlackToken;channel=$SlackChannel;text="whatever we are doing here went well";username=$SlackBotUserName}
  } Catch {
    # $_ is set to the ErrorRecord of the exception
    $err = $_.Exception
    Write-Debug $err.Message
    while( $err.InnerException ) {
              $err = $err.InnerException
              Write-Debug $err.Message
            };
    $errmessage = $err.Message;
    #set up to let yourself know how cool this is and that everythign went poorly
    $postSlackMessage = @{token=$SlackToken;channel=$SlackChannel;text="whatever we are doing here went poorly, investigate: $errmessage";username=$SlackBotUserName}
    
    Write-Error "whatever we are doing here went poorly, investigate: $errmessage" -EA Stop

  } Finally {
    #tell yourself know how cool this is and that everythign went well or poorly (whichever is correct as per reality)
    Invoke-RestMethod -Uri https://slack.com/api/chat.postMessage -Body $postSlackMessage
  }
}