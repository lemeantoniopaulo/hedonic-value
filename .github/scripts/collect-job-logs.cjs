const fs = require("node:fs");
const path = require("node:path");

module.exports = async function collect({ github, context, core, directory }) {
  fs.mkdirSync(directory, { recursive: true });
  const jobs = await github.paginate(github.rest.actions.listJobsForWorkflowRun, {
    ...context.repo, run_id: context.runId, filter: "latest", per_page: 100
  });
  const completed = jobs.filter(job => job.status === "completed");
  fs.writeFileSync(path.join(directory, "jobs.json"), JSON.stringify(jobs, null, 2));
  if (completed.length === 0) core.setFailed("No completed jobs available for log collection");
  for (const job of completed) {
    try {
      const response = await github.rest.actions.downloadJobLogsForWorkflowRun({
        ...context.repo, job_id: job.id
      });
      const data = response.data;
      if (typeof data !== "string" && !Buffer.isBuffer(data) && !(data instanceof ArrayBuffer)) {
        throw new Error("Unexpected log response type");
      }
      fs.writeFileSync(path.join(directory, job.id + ".log"),
        typeof data === "string" ? data : Buffer.from(data));
    } catch (error) {
      fs.writeFileSync(path.join(directory, job.id + "-error.txt"), String(error));
      core.setFailed("Unable to preserve complete log for job " + job.id);
    }
  }
};
