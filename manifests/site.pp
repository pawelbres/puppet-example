node default {

  notify { 'assignment_message':
    message => 'Configuration not found in puppet for this host'
  }

}
