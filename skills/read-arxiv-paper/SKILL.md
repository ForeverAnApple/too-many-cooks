---
name: read-arxiv-paper
description: Read an arxiv paper from a URL, download the TeX source, and produce a local summary
---

You will be given a URL of an arxiv paper, for example:

https://www.arxiv.org/abs/2601.07372

### Part 1: Normalize the URL

The goal is to fetch the TeX Source of the paper (not the PDF!), the URL always looks like this:

https://www.arxiv.org/src/2601.07372

Notice the /src/ in the url. Once you have the URL:

### Part 2: Gitignore references

If the current working directory is a git repository, check if `references/` is already in `.gitignore`. If not, add it. These are throwaway downloaded sources and summaries — they should never be committed.

### Part 3: Download the paper source

Fetch the url to a local .tar.gz file at `references/knowledge/{arxiv_id}.tar.gz` in the current working repository.

(If the file already exists, there is no need to re-download it).

### Part 4: Unpack the file in that folder

Unpack the contents into `references/knowledge/{arxiv_id}` directory.

### Part 5: Locate the entrypoint

Every latex source usually has an entrypoint, such as `main.tex` or something like that.

### Part 6: Read the paper

Once you've found the entrypoint, read the contents and then recurse through all other relevant source files to read the paper.

### Part 7: Report

Once you've read the paper, produce a summary of the paper into a markdown file at `references/knowledge/summary_{tag}.md`. Generate a reasonable `tag` like e.g. `conditional_memory` or whatever seems appropriate given the paper. Make sure the tag doesn't already exist so you're not overwriting files.

The summary should focus on practical takeaways: what the paper proposes, key results, and how the ideas might apply to the current project. Read relevant parts of the codebase to make explicit connections where possible.
