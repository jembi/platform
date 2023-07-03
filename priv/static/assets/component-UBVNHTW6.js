import {
  require_client,
  useStore
} from "./chunk-WCGBZ45P.js";
import {
  __toESM,
  require_react
} from "./chunk-PV4GFR55.js";

// js/workflow-editor/component.tsx
var import_react = __toESM(require_react());
var import_client = __toESM(require_client());
var WorkflowContext = (0, import_react.createContext)(null);
function WorkflowEditor() {
  const store = (0, import_react.useContext)(WorkflowContext);
  if (!store)
    throw new Error("Missing WorkflowContext.Provider in the tree");
  const { edges, jobs, triggers, addJob, addTrigger, addEdge, editJobUrl } = useStore(store);
  return /* @__PURE__ */ import_react.default.createElement("div", null, /* @__PURE__ */ import_react.default.createElement("h1", { className: "text-lg font-bold" }, "Workflow Diagram"), /* @__PURE__ */ import_react.default.createElement("h3", { className: "font-bold" }, "Triggers"), triggers.map(({ id, errors }) => /* @__PURE__ */ import_react.default.createElement("li", { key: id, className: "text-sm font-mono" }, id, " - ", JSON.stringify(errors, null, 2))), /* @__PURE__ */ import_react.default.createElement(
    "button",
    {
      className: "px-4 py-2 font-semibold text-sm bg-cyan-500 text-white rounded-full shadow-sm",
      onClick: () => addTrigger()
    },
    "Add Trigger"
  ), /* @__PURE__ */ import_react.default.createElement("h3", { className: "font-bold" }, "Jobs"), jobs.map(({ id, ...rest }) => /* @__PURE__ */ import_react.default.createElement("li", { key: id, className: "text-sm font-mono" }, /* @__PURE__ */ import_react.default.createElement(
    "a",
    {
      "data-phx-link": "patch",
      "data-phx-link-state": "push",
      href: editJobUrl.replace(":job_id", id)
    },
    id
  ), "- ", JSON.stringify(rest, null, 2))), /* @__PURE__ */ import_react.default.createElement(
    "button",
    {
      className: "px-4 py-2 font-semibold text-sm bg-cyan-500 text-white rounded-full shadow-sm",
      onClick: () => addJob()
    },
    "Add Job"
  ), /* @__PURE__ */ import_react.default.createElement("h3", { className: "font-bold" }, "Edges"), edges.map(({ id, errors }) => /* @__PURE__ */ import_react.default.createElement("li", { key: id, className: "text-sm font-mono" }, id, " - ", JSON.stringify(errors))), /* @__PURE__ */ import_react.default.createElement(
    "button",
    {
      className: "px-4 py-2 font-semibold text-sm bg-cyan-500 text-white rounded-full shadow-sm",
      onClick: () => addEdge()
    },
    "Add Edge"
  ));
}
function mount(el, workflowStore) {
  const componentRoot = (0, import_client.createRoot)(el);
  function update() {
    return componentRoot.render(
      /* @__PURE__ */ import_react.default.createElement(WorkflowContext.Provider, { value: workflowStore }, /* @__PURE__ */ import_react.default.createElement(WorkflowEditor, null))
    );
  }
  function unmount() {
    return componentRoot.unmount();
  }
  componentRoot.render(
    /* @__PURE__ */ import_react.default.createElement(WorkflowContext.Provider, { value: workflowStore }, /* @__PURE__ */ import_react.default.createElement(WorkflowEditor, null))
  );
  return { update, unmount };
}
export {
  mount
};
//# sourceMappingURL=data:application/json;base64,ewogICJ2ZXJzaW9uIjogMywKICAic291cmNlcyI6IFsiLi4vLi4vLi4vYXNzZXRzL2pzL3dvcmtmbG93LWVkaXRvci9jb21wb25lbnQudHN4Il0sCiAgInNvdXJjZXNDb250ZW50IjogWyJpbXBvcnQgUmVhY3QsIHsgY3JlYXRlQ29udGV4dCwgdXNlQ29udGV4dCB9IGZyb20gJ3JlYWN0JztcbmltcG9ydCB7IGNyZWF0ZVJvb3QgfSBmcm9tICdyZWFjdC1kb20vY2xpZW50JztcbmltcG9ydCB7IFN0b3JlQXBpLCB1c2VTdG9yZSB9IGZyb20gJ3p1c3RhbmQnO1xuaW1wb3J0IHsgV29ya2Zsb3dTdGF0ZSwgY3JlYXRlV29ya2Zsb3dTdG9yZSB9IGZyb20gJy4vc3RvcmUnO1xuXG5jb25zdCBXb3JrZmxvd0NvbnRleHQgPSBjcmVhdGVDb250ZXh0PFN0b3JlQXBpPFdvcmtmbG93U3RhdGU+IHwgbnVsbD4obnVsbCk7XG5cbmZ1bmN0aW9uIFdvcmtmbG93RWRpdG9yKCkge1xuICBjb25zdCBzdG9yZSA9IHVzZUNvbnRleHQoV29ya2Zsb3dDb250ZXh0KTtcbiAgaWYgKCFzdG9yZSkgdGhyb3cgbmV3IEVycm9yKCdNaXNzaW5nIFdvcmtmbG93Q29udGV4dC5Qcm92aWRlciBpbiB0aGUgdHJlZScpO1xuXG4gIGNvbnN0IHsgZWRnZXMsIGpvYnMsIHRyaWdnZXJzLCBhZGRKb2IsIGFkZFRyaWdnZXIsIGFkZEVkZ2UsIGVkaXRKb2JVcmwgfSA9XG4gICAgdXNlU3RvcmUoc3RvcmUpO1xuXG4gIC8vIE1heWJlIHB1bGwgZWRpdEpvYlVybCBhbmQgdGhlIGRhdGEtcGh4LSogYXR0cmlidXRlcyBpbnRvIGEgcHJvdmlkZXJcbiAgLy8gYW5kIGNvbXBvbmVudD9cblxuICByZXR1cm4gKFxuICAgIDxkaXY+XG4gICAgICA8aDEgY2xhc3NOYW1lPVwidGV4dC1sZyBmb250LWJvbGRcIj5Xb3JrZmxvdyBEaWFncmFtPC9oMT5cbiAgICAgIDxoMyBjbGFzc05hbWU9XCJmb250LWJvbGRcIj5UcmlnZ2VyczwvaDM+XG4gICAgICB7dHJpZ2dlcnMubWFwKCh7IGlkLCBlcnJvcnMgfSkgPT4gKFxuICAgICAgICA8bGkga2V5PXtpZH0gY2xhc3NOYW1lPVwidGV4dC1zbSBmb250LW1vbm9cIj5cbiAgICAgICAgICB7aWR9IC0ge0pTT04uc3RyaW5naWZ5KGVycm9ycywgbnVsbCwgMil9XG4gICAgICAgIDwvbGk+XG4gICAgICApKX1cbiAgICAgIDxidXR0b25cbiAgICAgICAgY2xhc3NOYW1lPXtcbiAgICAgICAgICAncHgtNCBweS0yIGZvbnQtc2VtaWJvbGQgdGV4dC1zbSBiZy1jeWFuLTUwMCB0ZXh0LXdoaXRlIHJvdW5kZWQtZnVsbCBzaGFkb3ctc20nXG4gICAgICAgIH1cbiAgICAgICAgb25DbGljaz17KCkgPT4gYWRkVHJpZ2dlcigpfVxuICAgICAgPlxuICAgICAgICBBZGQgVHJpZ2dlclxuICAgICAgPC9idXR0b24+XG5cbiAgICAgIDxoMyBjbGFzc05hbWU9XCJmb250LWJvbGRcIj5Kb2JzPC9oMz5cbiAgICAgIHtqb2JzLm1hcCgoeyBpZCwgLi4ucmVzdCB9KSA9PiAoXG4gICAgICAgIDxsaSBrZXk9e2lkfSBjbGFzc05hbWU9XCJ0ZXh0LXNtIGZvbnQtbW9ub1wiPlxuICAgICAgICAgIDxhXG4gICAgICAgICAgICBkYXRhLXBoeC1saW5rPVwicGF0Y2hcIlxuICAgICAgICAgICAgZGF0YS1waHgtbGluay1zdGF0ZT1cInB1c2hcIlxuICAgICAgICAgICAgaHJlZj17ZWRpdEpvYlVybC5yZXBsYWNlKCc6am9iX2lkJywgaWQpfVxuICAgICAgICAgID5cbiAgICAgICAgICAgIHtpZH1cbiAgICAgICAgICA8L2E+XG4gICAgICAgICAgLSB7SlNPTi5zdHJpbmdpZnkocmVzdCwgbnVsbCwgMil9XG4gICAgICAgIDwvbGk+XG4gICAgICApKX1cbiAgICAgIDxidXR0b25cbiAgICAgICAgY2xhc3NOYW1lPXtcbiAgICAgICAgICAncHgtNCBweS0yIGZvbnQtc2VtaWJvbGQgdGV4dC1zbSBiZy1jeWFuLTUwMCB0ZXh0LXdoaXRlIHJvdW5kZWQtZnVsbCBzaGFkb3ctc20nXG4gICAgICAgIH1cbiAgICAgICAgb25DbGljaz17KCkgPT4gYWRkSm9iKCl9XG4gICAgICA+XG4gICAgICAgIEFkZCBKb2JcbiAgICAgIDwvYnV0dG9uPlxuXG4gICAgICA8aDMgY2xhc3NOYW1lPVwiZm9udC1ib2xkXCI+RWRnZXM8L2gzPlxuICAgICAge2VkZ2VzLm1hcCgoeyBpZCwgZXJyb3JzIH0pID0+IChcbiAgICAgICAgPGxpIGtleT17aWR9IGNsYXNzTmFtZT1cInRleHQtc20gZm9udC1tb25vXCI+XG4gICAgICAgICAge2lkfSAtIHtKU09OLnN0cmluZ2lmeShlcnJvcnMpfVxuICAgICAgICA8L2xpPlxuICAgICAgKSl9XG4gICAgICA8YnV0dG9uXG4gICAgICAgIGNsYXNzTmFtZT17XG4gICAgICAgICAgJ3B4LTQgcHktMiBmb250LXNlbWlib2xkIHRleHQtc20gYmctY3lhbi01MDAgdGV4dC13aGl0ZSByb3VuZGVkLWZ1bGwgc2hhZG93LXNtJ1xuICAgICAgICB9XG4gICAgICAgIG9uQ2xpY2s9eygpID0+IGFkZEVkZ2UoKX1cbiAgICAgID5cbiAgICAgICAgQWRkIEVkZ2VcbiAgICAgIDwvYnV0dG9uPlxuICAgIDwvZGl2PlxuICApO1xufVxuXG5leHBvcnQgZnVuY3Rpb24gbW91bnQoXG4gIGVsOiBFbGVtZW50IHwgRG9jdW1lbnRGcmFnbWVudCxcbiAgd29ya2Zsb3dTdG9yZTogUmV0dXJuVHlwZTx0eXBlb2YgY3JlYXRlV29ya2Zsb3dTdG9yZT5cbikge1xuICBjb25zdCBjb21wb25lbnRSb290ID0gY3JlYXRlUm9vdChlbCk7XG5cbiAgLy8gVE9ETzogd2UgbWF5IG5vdCBuZWVkIHRoaXMgaWYgd2UgYXJlIGRvaW5nIGFsbCBjb21tdW5pY2F0aW9uIHRocm91Z2ggdGhlIHN0b3JlXG4gIGZ1bmN0aW9uIHVwZGF0ZSgpIHtcbiAgICByZXR1cm4gY29tcG9uZW50Um9vdC5yZW5kZXIoXG4gICAgICA8V29ya2Zsb3dDb250ZXh0LlByb3ZpZGVyIHZhbHVlPXt3b3JrZmxvd1N0b3JlfT5cbiAgICAgICAgPFdvcmtmbG93RWRpdG9yIC8+XG4gICAgICA8L1dvcmtmbG93Q29udGV4dC5Qcm92aWRlcj5cbiAgICApO1xuICB9XG5cbiAgZnVuY3Rpb24gdW5tb3VudCgpIHtcbiAgICByZXR1cm4gY29tcG9uZW50Um9vdC51bm1vdW50KCk7XG4gIH1cblxuICBjb21wb25lbnRSb290LnJlbmRlcihcbiAgICA8V29ya2Zsb3dDb250ZXh0LlByb3ZpZGVyIHZhbHVlPXt3b3JrZmxvd1N0b3JlfT5cbiAgICAgIDxXb3JrZmxvd0VkaXRvciAvPlxuICAgIDwvV29ya2Zsb3dDb250ZXh0LlByb3ZpZGVyPlxuICApO1xuXG4gIHJldHVybiB7IHVwZGF0ZSwgdW5tb3VudCB9O1xufVxuIl0sCiAgIm1hcHBpbmdzIjogIjs7Ozs7Ozs7OztBQUFBLG1CQUFpRDtBQUNqRCxvQkFBMkI7QUFJM0IsSUFBTSxzQkFBa0IsNEJBQThDLElBQUk7QUFFMUUsU0FBUyxpQkFBaUI7QUFDeEIsUUFBTSxZQUFRLHlCQUFXLGVBQWU7QUFDeEMsTUFBSSxDQUFDO0FBQU8sVUFBTSxJQUFJLE1BQU0sOENBQThDO0FBRTFFLFFBQU0sRUFBRSxPQUFPLE1BQU0sVUFBVSxRQUFRLFlBQVksU0FBUyxXQUFXLElBQ3JFLFNBQVMsS0FBSztBQUtoQixTQUNFLDZCQUFBQSxRQUFBLGNBQUMsYUFDQyw2QkFBQUEsUUFBQSxjQUFDLFFBQUcsV0FBVSx1QkFBb0Isa0JBQWdCLEdBQ2xELDZCQUFBQSxRQUFBLGNBQUMsUUFBRyxXQUFVLGVBQVksVUFBUSxHQUNqQyxTQUFTLElBQUksQ0FBQyxFQUFFLElBQUksT0FBTyxNQUMxQiw2QkFBQUEsUUFBQSxjQUFDLFFBQUcsS0FBSyxJQUFJLFdBQVUsdUJBQ3BCLElBQUcsT0FBSSxLQUFLLFVBQVUsUUFBUSxNQUFNLENBQUMsQ0FDeEMsQ0FDRCxHQUNELDZCQUFBQSxRQUFBO0FBQUEsSUFBQztBQUFBO0FBQUEsTUFDQyxXQUNFO0FBQUEsTUFFRixTQUFTLE1BQU0sV0FBVztBQUFBO0FBQUEsSUFDM0I7QUFBQSxFQUVELEdBRUEsNkJBQUFBLFFBQUEsY0FBQyxRQUFHLFdBQVUsZUFBWSxNQUFJLEdBQzdCLEtBQUssSUFBSSxDQUFDLEVBQUUsSUFBSSxHQUFHLEtBQUssTUFDdkIsNkJBQUFBLFFBQUEsY0FBQyxRQUFHLEtBQUssSUFBSSxXQUFVLHVCQUNyQiw2QkFBQUEsUUFBQTtBQUFBLElBQUM7QUFBQTtBQUFBLE1BQ0MsaUJBQWM7QUFBQSxNQUNkLHVCQUFvQjtBQUFBLE1BQ3BCLE1BQU0sV0FBVyxRQUFRLFdBQVcsRUFBRTtBQUFBO0FBQUEsSUFFckM7QUFBQSxFQUNILEdBQUksTUFDRCxLQUFLLFVBQVUsTUFBTSxNQUFNLENBQUMsQ0FDakMsQ0FDRCxHQUNELDZCQUFBQSxRQUFBO0FBQUEsSUFBQztBQUFBO0FBQUEsTUFDQyxXQUNFO0FBQUEsTUFFRixTQUFTLE1BQU0sT0FBTztBQUFBO0FBQUEsSUFDdkI7QUFBQSxFQUVELEdBRUEsNkJBQUFBLFFBQUEsY0FBQyxRQUFHLFdBQVUsZUFBWSxPQUFLLEdBQzlCLE1BQU0sSUFBSSxDQUFDLEVBQUUsSUFBSSxPQUFPLE1BQ3ZCLDZCQUFBQSxRQUFBLGNBQUMsUUFBRyxLQUFLLElBQUksV0FBVSx1QkFDcEIsSUFBRyxPQUFJLEtBQUssVUFBVSxNQUFNLENBQy9CLENBQ0QsR0FDRCw2QkFBQUEsUUFBQTtBQUFBLElBQUM7QUFBQTtBQUFBLE1BQ0MsV0FDRTtBQUFBLE1BRUYsU0FBUyxNQUFNLFFBQVE7QUFBQTtBQUFBLElBQ3hCO0FBQUEsRUFFRCxDQUNGO0FBRUo7QUFFTyxTQUFTLE1BQ2QsSUFDQSxlQUNBO0FBQ0EsUUFBTSxvQkFBZ0IsMEJBQVcsRUFBRTtBQUduQyxXQUFTLFNBQVM7QUFDaEIsV0FBTyxjQUFjO0FBQUEsTUFDbkIsNkJBQUFBLFFBQUEsY0FBQyxnQkFBZ0IsVUFBaEIsRUFBeUIsT0FBTyxpQkFDL0IsNkJBQUFBLFFBQUEsY0FBQyxvQkFBZSxDQUNsQjtBQUFBLElBQ0Y7QUFBQSxFQUNGO0FBRUEsV0FBUyxVQUFVO0FBQ2pCLFdBQU8sY0FBYyxRQUFRO0FBQUEsRUFDL0I7QUFFQSxnQkFBYztBQUFBLElBQ1osNkJBQUFBLFFBQUEsY0FBQyxnQkFBZ0IsVUFBaEIsRUFBeUIsT0FBTyxpQkFDL0IsNkJBQUFBLFFBQUEsY0FBQyxvQkFBZSxDQUNsQjtBQUFBLEVBQ0Y7QUFFQSxTQUFPLEVBQUUsUUFBUSxRQUFRO0FBQzNCOyIsCiAgIm5hbWVzIjogWyJSZWFjdCJdCn0K
