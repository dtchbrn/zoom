/*
 *  A Z-Machine
 *  Copyright (C) 2000 Andrew Hunter
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/*
 * Parse options
 */

#include <stdio.h>
#include <stdlib.h>

#include "zmachine.h"
#include "options.h"

#if OPT_TYPE==0

#include <argp.h>

const char* argp_program_version     = "Zoom " VERSION;
const char* argp_program_bug_address = "bugs@logicalshift.co.uk";
static char doc[]      = "Zoom - A Z-Machine";
static char args_doc[] = "story-file [save-file]";

static struct argp_option options[] = {
  { "warnings", 'w', 0, 0, "Display interpreter warnings" },
  { "fatal", 'W', 0, 0, "Warnings are fatal" },
#ifdef TRACKING
  { "trackobjs", 'O', 0, 0, "Track object movement" },
  { "trackattrs", 'A', 0, 0, "Track attribute testing/setting" },
  { "trackprops", 'P', 0, 0, "Track property reading/writing" },
#endif
  { 0 }
};

static error_t parse_opt(int key, char* arg, struct argp_state* state)
{
  arguments* args = state->input;
  
  switch (key)
    {
    case 'w':
      args->warning_level = 1;
      break;
    case 'W':
      args->warning_level = 2;
      break;

    case 'O':
      args->track_objs = 1;
      break;
    case 'A':
      args->track_attr = 1;
      break;
    case 'P':
      args->track_props = 1;
      
    case ARGP_KEY_ARG:
      if (state->arg_num >= 2)
	argp_usage(state);

      args->arg[state->arg_num] = arg;
      break;

    case ARGP_KEY_END:
      if (state->arg_num < 1)
	argp_usage(state);
      break;
      
    default:
      return ARGP_ERR_UNKNOWN;
    }

  return 0;
}

static struct argp argp = { options, parse_opt, args_doc, doc };

void get_options(int argc, char** argv, arguments* args)
{
  args->arg[0] = NULL;
  args->arg[1] = NULL;
  args->warning_level = 0;
  
  args->track_objs  = 0;
  args->track_attr  = 0;
  args->track_props = 0;
   
  argp_parse(&argp, argc, argv, 0, 0, args);

  args->story_file = args->arg[0];
  args->save_file  = args->arg[1];
}

#else
# if OPT_TYPE==1

# include <unistd.h>

void get_options(int argc, char** argv, arguments* args)
{
  int opt;

  while ((opt=getopt(argc, argv, "?hV")) != -1)
    {
      switch (opt)
	{
	case '?': /* ? */
	case 'h': /* h */
	  printf("Usage: %s [OPTION...] story-file [save-file]\n", argv[0]);
	  printf("  Where option is one of:\n");
	  printf("    -? or -h   display this text\n");
	  printf("    -V         display version information\n");
	  printf("Zoom is copyright (C) Andrew Hunter, 2000\n");
	  exit(0);
	  break;

	case 'V': /* V */
	  printf("Zoom version " VERSION "\n");
	  exit(0);
	  break;
	}
    }

  if (optind >= argc || (optind-argc)>2)
    {
      printf("Usage: %s [OPTION...] story-file [save-file]\n",
	     argv[0]);
      exit (1);
   }

  args->story_file = argv[optind];

  if ((optind-argc) == 2)
    args->save_file = argv[optind+1];
  else
    args->save_file = NULL;
}

# else

void get_options(int argc, char** argv, arguments* args)
{
  if (argc == 2)
    {
      args->story_file = argv[1];
      args->save_file  = NULL;
    }
  else if (argc == 3)
    {
      args->story_file = argv[1];
      args->save_file  = argv[2];      
    }
  else
    {
      printf("Usage: %s story-file [save-file]\n", argv[0]);
      exit(1);
    }
}

# endif
#endif
