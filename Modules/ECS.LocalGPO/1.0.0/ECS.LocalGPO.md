# ECS.LocalGPO

## Table of contents

## Why I created this module
I love to automate things, and my language of choice is PowerShell.  I setup a decent number of SQL servers in a year, and it’s a pretty time-consuming process if you do it by hand.  Me, I’ve pretty much scripted everything from deploying the VM’s all the way to setting up an AAG.  There was one thing missing though, the ability to manage Windows local GPO user right assignments.  More specifically the setting “perform volume maintenance tasks”.  It was a little comment block on my script, and a lot of time’s I’d blow by it and forget about it.  After being frustrated enough, I decided I was going to put together something, even if it was a bit of a hack, and that’s what started the ECS.LocalGPO module.  

It is my hope that over time it will be expanded to include setting beyond user right assignments, and even better, that Microsoft would just release Powershell commands so these don’t have to exist.



